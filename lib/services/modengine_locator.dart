import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'pre_cache_finder.dart';

class ModEngineLocator {
  ModEngineLocator({
    required Future<Directory> Function() appFolder,
    required Future<Directory?> Function() preCache,
  })  : _appFolder = appFolder,
        _preCache = preCache;

  /// Production wiring: app folder via `path_provider`,
  /// pre-cache via [PreCacheFinder.fromPlatform].
  factory ModEngineLocator.production() {
    final finder = PreCacheFinder.fromPlatform();
    return ModEngineLocator(
      appFolder: getApplicationSupportDirectory,
      preCache: finder.find,
    );
  }

  static const _me2FolderName = 'modengine2';
  static const _launcherName = 'modengine2_launcher.exe';
  static const _versionFileName = '.version';

  final Future<Directory> Function() _appFolder;
  final Future<Directory?> Function() _preCache;

  Future<Directory> resolve() async {
    final target = await _me2Folder();
    final source = await _preCache();
    if (source == null) {
      throw StateError('ModEngine2 pre-cache not available.');
    }
    if (_isUpToDate(target, source)) return target;
    _rebuild(target, source);
    return target;
  }

  Future<File> launcherExe() async {
    final target = await _me2Folder();
    return File(p.join(target.path, _launcherName));
  }

  Future<Directory> _me2Folder() async {
    final app = await _appFolder();
    return Directory(p.join(app.path, _me2FolderName));
  }

  bool _isUpToDate(Directory target, Directory source) {
    if (!target.existsSync()) return false;
    final targetVersion = _readVersion(target);
    if (targetVersion == null) return false;
    return targetVersion == _readVersion(source);
  }

  void _rebuild(Directory target, Directory source) {
    if (target.existsSync()) target.deleteSync(recursive: true);
    target.createSync(recursive: true);
    _copyDirectory(source, target);
  }

  String? _readVersion(Directory dir) {
    final file = File(p.join(dir.path, _versionFileName));
    return file.existsSync() ? file.readAsStringSync().trim() : null;
  }

  void _copyDirectory(Directory source, Directory destination) {
    for (final entity in source.listSync(recursive: true)) {
      final relative = p.relative(entity.path, from: source.path);
      final target = p.join(destination.path, relative);
      if (entity is Directory) {
        Directory(target).createSync(recursive: true);
      } else if (entity is File) {
        Directory(p.dirname(target)).createSync(recursive: true);
        entity.copySync(target);
      }
    }
  }
}
