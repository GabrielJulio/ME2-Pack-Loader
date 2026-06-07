import 'dart:io';

import '../../models/game_config.dart';

abstract class ConfigState {}

class ConfigInitial extends ConfigState {}

class ConfigLoading extends ConfigState {}

class ConfigLoaded extends ConfigState {
  final GameConfig config;

  /// The pack file currently being edited (`<slug>.toml`).
  final File configFile;

  /// The game's base directory.
  final Directory baseDir;

  /// The slug of the pack currently loaded into the editor.
  final String packSlug;

  ConfigLoaded({
    required this.config,
    required this.configFile,
    required this.baseDir,
    required this.packSlug,
  });
}

class ConfigError extends ConfigState {
  final String message;
  ConfigError(this.message);
}
