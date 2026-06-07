import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../models/data_dir_status.dart';
import '../models/disk_check_result.dart';

class DataDirService {
  DataDirService({
    required Future<Directory> Function() appFolder,
    Future<int> Function(String path)? freeBytesAt,
  })  : _appFolder = appFolder,
        _freeBytesAt = freeBytesAt ?? _freeBytesViaDf;

  static const _pointerFileName = 'pointer.json';
  static const _me2FolderName = 'modengine2';

  final Future<Directory> Function() _appFolder;
  final Future<int> Function(String path) _freeBytesAt;

  Future<DiskCheckResult> checkSpace(String destinationPath) async {
    final needed = await directorySize(await gamesRoot());
    final free = await _freeBytesAt(destinationPath);
    return DiskCheckResult.compute(neededBytes: needed, freeBytes: free);
  }

  /// Production fallback: uses `df -PB1 <path>` on Linux.
  /// Windows free-space lookup is TODO (returns 0 — call sites must guard).
  static Future<int> _freeBytesViaDf(String path) async {
    if (!Platform.isLinux) return 0;
    final result = await Process.run('df', ['-PB1', path]);
    if (result.exitCode != 0) return 0;
    final lines = (result.stdout as String).trim().split('\n');
    if (lines.length < 2) return 0;
    final fields = lines[1].split(RegExp(r'\s+'));
    if (fields.length < 4) return 0;
    return int.tryParse(fields[3]) ?? 0;
  }

  Future<Directory> gamesRoot() async {
    final root = _computeGamesRoot(await probe(), await _appFolder());
    root.createSync(recursive: true);
    return root;
  }

  Future<DataDirStatus> probe() async {
    final pointer = await _pointerFile();
    if (!pointer.existsSync()) return const DefaultDataDir();
    final raw = pointer.readAsStringSync().trim();
    if (raw.isEmpty) return const DefaultDataDir();
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final path = decoded['dataDir'] as String?;
    if (path == null || path.isEmpty) return const DefaultDataDir();
    return Directory(path).existsSync()
        ? CustomDataDir(path)
        : MissingDataDir(path);
  }

  Future<void> moveTo({
    required String? newDataDir,
    required List<String> gameFolderSlugs,
  }) async {
    final sourceRoot = await gamesRoot();
    final destinationRoot = _computeGamesRoot(
      newDataDir == null ? const DefaultDataDir() : CustomDataDir(newDataDir),
      await _appFolder(),
    );
    destinationRoot.createSync(recursive: true);

    for (final slug in gameFolderSlugs) {
      final src = Directory(p.join(sourceRoot.path, slug));
      if (!src.existsSync()) continue;
      final dst = Directory(p.join(destinationRoot.path, slug));
      _copyDirectory(src, dst);
    }

    await setDataDir(newDataDir);

    for (final slug in gameFolderSlugs) {
      final src = Directory(p.join(sourceRoot.path, slug));
      if (src.existsSync()) src.deleteSync(recursive: true);
    }
  }

  Directory _computeGamesRoot(DataDirStatus status, Directory app) {
    final segments = switch (status) {
      DefaultDataDir() => [app.path, _me2FolderName],
      CustomDataDir(:final path) => [path, 'me2_pack_loader', _me2FolderName],
      MissingDataDir(:final path) => [path, 'me2_pack_loader', _me2FolderName],
    };
    return Directory(p.joinAll(segments));
  }

  void _copyDirectory(Directory source, Directory destination) {
    destination.createSync(recursive: true);
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

  Future<int> directorySize(Directory dir) async {
    if (!dir.existsSync()) return 0;
    var total = 0;
    for (final entity in dir.listSync(recursive: true)) {
      if (entity is File) total += entity.lengthSync();
    }
    return total;
  }

  Future<void> setDataDir(String? path) async {
    final pointer = await _pointerFile();
    final tmp = File('${pointer.path}.tmp');
    tmp.writeAsStringSync(jsonEncode({'dataDir': path}));
    tmp.renameSync(pointer.path);
  }

  Future<File> _pointerFile() async {
    final app = await _appFolder();
    return File(p.join(app.path, _pointerFileName));
  }
}
