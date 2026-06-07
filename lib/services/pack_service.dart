import 'dart:io';

import 'package:path/path.dart' as p;

import '../models/pack.dart';

/// Default ModEngine2 TOML — used when seeding a fresh game folder's
/// first pack (`default.toml`).
const String defaultPackContent = '''
[modengine]
debug = false
external_dlls = []

[extension.mod_loader]
enabled = true
loose_params = false
mods = [
    { enabled = true, name = "default", path = "mod" }
]

[extension.scylla_hide]
enabled = false
''';

class PackService {
  static const String activeFileName = 'config.toml';
  static const String defaultPackSlug = 'default';

  Future<List<Pack>> list(Directory baseDir) async {
    if (!baseDir.existsSync()) return const [];
    final packs = <Pack>[];
    for (final entity in baseDir.listSync()) {
      if (entity is! File) continue;
      final name = p.basename(entity.path);
      if (!name.endsWith('.toml')) continue;
      if (name == activeFileName) continue;
      packs.add(Pack(
        slug: p.basenameWithoutExtension(name),
        file: entity,
        modifiedAt: entity.lastModifiedSync(),
      ));
    }
    packs.sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
    return packs;
  }

  Future<void> activate(Directory baseDir, Pack pack) async {
    final mirror = File(p.join(baseDir.path, activeFileName));
    final bytes = pack.file.readAsBytesSync();
    mirror.writeAsBytesSync(bytes);
    pack.file.setLastModifiedSync(DateTime.now());
  }

  Future<void> create(Directory baseDir, String slug, String content) async {
    if (slug == 'config') {
      throw ArgumentError.value(slug, 'slug', 'Reserved pack name.');
    }
    final file = _fileFor(baseDir, slug);
    if (file.existsSync()) {
      throw StateError('Pack "$slug" already exists.');
    }
    file.writeAsStringSync(content);
  }

  Future<void> delete(Directory baseDir, String slug) async {
    final file = _fileFor(baseDir, slug);
    if (file.existsSync()) file.deleteSync();
  }

  Future<void> rename(Directory baseDir, String oldSlug, String newSlug) async {
    if (newSlug == 'config') {
      throw ArgumentError.value(newSlug, 'newSlug', 'Reserved pack name.');
    }
    final newFile = _fileFor(baseDir, newSlug);
    if (newFile.existsSync()) {
      throw StateError('Pack "$newSlug" already exists.');
    }
    _fileFor(baseDir, oldSlug).renameSync(newFile.path);
  }

  File _fileFor(Directory baseDir, String slug) =>
      File(p.join(baseDir.path, '$slug.toml'));

  Future<String?> activeSlug(Directory baseDir) async {
    final mirror = File(p.join(baseDir.path, activeFileName));
    if (!mirror.existsSync()) return null;
    final mirrorContent = mirror.readAsStringSync();
    final packs = await list(baseDir);
    for (final pack in packs) {
      if (pack.file.readAsStringSync() == mirrorContent) return pack.slug;
    }
    return null;
  }
}
