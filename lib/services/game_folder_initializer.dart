import 'dart:io';

import 'pack_service.dart';

/// Seeds a newly-activated game folder with a `default.toml` pack and
/// mirrors it to `config.toml` so the game is launchable immediately.
class GameFolderInitializer {
  GameFolderInitializer({PackService? packService})
      : _packs = packService ?? PackService();

  final PackService _packs;

  Future<void> initialize(Directory baseDir) async {
    final packs = await _packs.list(baseDir);
    if (packs.isEmpty) {
      await _packs.create(
        baseDir,
        PackService.defaultPackSlug,
        defaultPackContent,
      );
    }
    final freshPacks = await _packs.list(baseDir);
    if (freshPacks.isNotEmpty) {
      await _packs.activate(baseDir, freshPacks.first);
    }
  }
}
