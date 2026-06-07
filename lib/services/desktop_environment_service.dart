import 'dart:io';

import 'package:flutter/material.dart';

/// Detects the host desktop environment and reads the GNOME accent color
/// when available. Per ADR-0001: guarded with `Platform.isLinux` and
/// returns sentinel values on unsupported platforms.
class DesktopEnvironmentService {
  DesktopEnvironmentService({
    required this.environment,
    required this.isLinux,
    required this.gsettingsResult,
  });

  factory DesktopEnvironmentService.fromPlatform() {
    return DesktopEnvironmentService(
      environment: Platform.environment,
      isLinux: Platform.isLinux,
      gsettingsResult: _readGsettingsAccent,
    );
  }

  final Map<String, String> environment;
  final bool isLinux;
  final Future<String?> Function() gsettingsResult;

  /// Maps GNOME 47+ named accent colors to the upstream palette hex values.
  static const Map<String, Color> _gnomeAccentPalette = {
    'blue': Color(0xFF3584E4),
    'teal': Color(0xFF2190A4),
    'green': Color(0xFF3A944A),
    'yellow': Color(0xFFC88800),
    'orange': Color(0xFFED5B00),
    'red': Color(0xFFE62D42),
    'pink': Color(0xFFD56199),
    'purple': Color(0xFF9141AC),
    'slate': Color(0xFF6F8396),
  };

  bool isGnome() {
    if (!isLinux) return false;
    final raw = environment['XDG_CURRENT_DESKTOP'];
    if (raw == null || raw.isEmpty) return false;
    return raw.toUpperCase().split(':').contains('GNOME');
  }

  Future<Color?> gnomeAccentColor() async {
    if (!isLinux) return null;
    final name = await gsettingsResult();
    if (name == null) return null;
    return _gnomeAccentPalette[name.toLowerCase()];
  }

  static Future<String?> _readGsettingsAccent() async {
    if (!Platform.isLinux) return null;
    try {
      final result = await Process.run(
        'gsettings',
        ['get', 'org.gnome.desktop.interface', 'accent-color'],
      );
      if (result.exitCode != 0) return null;
      final raw = (result.stdout as String).trim();
      // Strip surrounding quotes: `'blue'` → `blue`
      return raw.replaceAll(RegExp(r"^'|'$"), '').toLowerCase();
    } catch (_) {
      return null;
    }
  }
}
