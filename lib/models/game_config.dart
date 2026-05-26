import 'package:flutter/foundation.dart';

import 'mod.dart';

@immutable
class GameConfig {
  final bool debug;
  final List<String> externalDlls;
  final bool modLoaderEnabled;
  final bool looseParams;
  final List<Mod> mods;
  final bool scyllaHideEnabled;

  const GameConfig({
    required this.debug,
    required this.externalDlls,
    required this.modLoaderEnabled,
    required this.looseParams,
    required this.mods,
    required this.scyllaHideEnabled,
  });

  static const GameConfig defaults = GameConfig(
    debug: false,
    externalDlls: [],
    modLoaderEnabled: true,
    looseParams: false,
    mods: [Mod(enabled: true, name: 'default', path: 'mod')],
    scyllaHideEnabled: false,
  );

  GameConfig copyWith({
    bool? debug,
    List<String>? externalDlls,
    bool? modLoaderEnabled,
    bool? looseParams,
    List<Mod>? mods,
    bool? scyllaHideEnabled,
  }) =>
      GameConfig(
        debug: debug ?? this.debug,
        externalDlls: externalDlls ?? this.externalDlls,
        modLoaderEnabled: modLoaderEnabled ?? this.modLoaderEnabled,
        looseParams: looseParams ?? this.looseParams,
        mods: mods ?? this.mods,
        scyllaHideEnabled: scyllaHideEnabled ?? this.scyllaHideEnabled,
      );

  @override
  bool operator ==(Object other) =>
      other is GameConfig &&
      other.debug == debug &&
      other.externalDlls == externalDlls &&
      other.modLoaderEnabled == modLoaderEnabled &&
      other.looseParams == looseParams &&
      other.mods == mods &&
      other.scyllaHideEnabled == scyllaHideEnabled;

  @override
  int get hashCode => Object.hash(
        debug,
        externalDlls,
        modLoaderEnabled,
        looseParams,
        mods,
        scyllaHideEnabled,
      );
}
