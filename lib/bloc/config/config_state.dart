import 'dart:io';

import '../../models/game_config.dart';

abstract class ConfigState {}

class ConfigInitial extends ConfigState {}

class ConfigLoading extends ConfigState {}

class ConfigLoaded extends ConfigState {
  final GameConfig config;
  final File configFile;
  final Directory baseDir;

  ConfigLoaded({
    required this.config,
    required this.configFile,
    required this.baseDir,
  });
}

class ConfigError extends ConfigState {
  final String message;
  ConfigError(this.message);
}
