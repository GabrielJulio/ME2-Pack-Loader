import 'dart:io';

import 'package:path/path.dart' as p;

class PreCacheFinder {
  PreCacheFinder({
    required this.bundleDirOverride,
    required this.appDir,
    required this.executablePath,
    required this.isLinux,
    required this.isWindows,
  });

  /// Production constructor reading the real platform environment.
  factory PreCacheFinder.fromPlatform() {
    return PreCacheFinder(
      bundleDirOverride: Platform.environment['ME2_BUNDLE_DIR'],
      appDir: Platform.environment['APPDIR'],
      executablePath: Platform.resolvedExecutable,
      isLinux: Platform.isLinux,
      isWindows: Platform.isWindows,
    );
  }

  final String? bundleDirOverride;
  final String? appDir;
  final String? executablePath;
  final bool isLinux;
  final bool isWindows;

  Future<Directory?> find() async {
    if (bundleDirOverride != null) {
      final dir = Directory(bundleDirOverride!);
      if (dir.existsSync()) return dir;
    }
    if (isLinux && appDir != null) {
      final dir = Directory(p.join(appDir!, 'usr', 'share', 'modengine2'));
      if (dir.existsSync()) return dir;
    }
    if (isWindows && executablePath != null) {
      final dir = Directory(p.join(p.dirname(executablePath!), 'modengine2'));
      if (dir.existsSync()) return dir;
    }
    return null;
  }
}
