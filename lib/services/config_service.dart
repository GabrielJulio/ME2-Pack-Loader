import 'dart:io';

import 'package:toml/toml.dart';

import '../models/game_config.dart';
import '../models/mod.dart';

class ConfigService {
  static const _configFileName = 'dark_souls_3.toml';

  Future<File> resolveConfig(Directory base) async {
    final file = File('${base.path}/$_configFileName');
    if (!await file.exists()) {
      await file.writeAsString(_defaultToml);
    }
    return file;
  }

  Future<GameConfig> read(File file) async {
    final content = await file.readAsString();
    final map = TomlDocument.parse(content).toMap();

    final modengine = map['modengine'] as Map<String, dynamic>? ?? {};
    final ext = map['extension'] as Map<String, dynamic>? ?? {};
    final modLoader = ext['mod_loader'] as Map<String, dynamic>? ?? {};
    final scyllaHide = ext['scylla_hide'] as Map<String, dynamic>? ?? {};

    final rawDlls = modengine['external_dlls'] as List<dynamic>? ?? [];
    final rawMods = modLoader['mods'] as List<dynamic>? ?? [];

    return GameConfig(
      debug: modengine['debug'] as bool? ?? false,
      externalDlls: rawDlls.map((e) => e.toString()).toList(),
      modLoaderEnabled: modLoader['enabled'] as bool? ?? true,
      looseParams: modLoader['loose_params'] as bool? ?? false,
      mods: rawMods
          .map((e) => Mod.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      scyllaHideEnabled: scyllaHide['enabled'] as bool? ?? false,
    );
  }

  Future<void> write(File file, GameConfig config) async {
    final buf = StringBuffer();

    buf.writeln('[modengine]');
    buf.writeln('debug = ${config.debug}');

    if (config.externalDlls.isEmpty) {
      buf.writeln('external_dlls = []');
    } else {
      buf.writeln('external_dlls = [');
      for (final dll in config.externalDlls) {
        buf.writeln('    "$dll",');
      }
      buf.writeln(']');
    }

    buf.writeln();
    buf.writeln('[extension.mod_loader]');
    buf.writeln('enabled = ${config.modLoaderEnabled}');
    buf.writeln('loose_params = ${config.looseParams}');

    if (config.mods.isEmpty) {
      buf.writeln('mods = []');
    } else {
      buf.writeln('mods = [');
      for (final mod in config.mods) {
        buf.writeln(
          '    { enabled = ${mod.enabled}, name = "${mod.name}", path = "${mod.path}" },',
        );
      }
      buf.writeln(']');
    }

    buf.writeln();
    buf.writeln('[extension.scylla_hide]');
    buf.writeln('enabled = ${config.scyllaHideEnabled}');

    await file.writeAsString(buf.toString());
  }

  Future<void> touch(File file) async {
    await file.setLastModified(DateTime.now());
  }
}

const _defaultToml = '''
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
