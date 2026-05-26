import 'dart:io';

import 'package:path/path.dart' as p;

class ModService {

  bool isFolderEmpty(Directory base, String relPath) {
    final dir = Directory(p.join(base.path, relPath));
    if (!dir.existsSync()) return true;
    return dir.listSync(recursive: true).whereType<File>().isEmpty;
  }

  Future<void> createFolder(Directory base, String slug) async {
    await Directory(p.join(base.path, slug)).create(recursive: true);
  }

  Future<void> deleteFolder(Directory base, String relPath) async {
    final dir = Directory(p.join(base.path, relPath));
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  Future<void> importFiles(
    Directory base,
    String modPath,
    List<String> srcPaths,
  ) async {
    final destDir = Directory(p.join(base.path, modPath));
    if (!await destDir.exists()) {
      await destDir.create(recursive: true);
    }
    for (final src in srcPaths) {
      final dest = File(p.join(destDir.path, p.basename(src)));
      await File(src).copy(dest.path);
    }
  }

  bool slugExists(Directory base, String slug) {
    return Directory(p.join(base.path, slug)).existsSync();
  }
}
