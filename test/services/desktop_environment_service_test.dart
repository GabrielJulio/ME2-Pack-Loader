import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:me2_pack_loader/services/desktop_environment_service.dart';

void main() {
  group('DesktopEnvironmentService.isGnome', () {
    test('returns true on Linux when XDG_CURRENT_DESKTOP mentions GNOME', () {
      final service = DesktopEnvironmentService(
        environment: const {'XDG_CURRENT_DESKTOP': 'GNOME'},
        isLinux: true,
        gsettingsResult: () async => 'blue',
      );

      expect(service.isGnome(), isTrue);
    });

    test('also matches when XDG_CURRENT_DESKTOP is colon-separated (e.g. "ubuntu:GNOME")',
        () {
      final service = DesktopEnvironmentService(
        environment: const {'XDG_CURRENT_DESKTOP': 'ubuntu:GNOME'},
        isLinux: true,
        gsettingsResult: () async => null,
      );

      expect(service.isGnome(), isTrue);
    });

    test('returns false when not on Linux even if env says GNOME', () {
      final service = DesktopEnvironmentService(
        environment: const {'XDG_CURRENT_DESKTOP': 'GNOME'},
        isLinux: false,
        gsettingsResult: () async => null,
      );

      expect(service.isGnome(), isFalse);
    });

    test('returns false on Linux when XDG_CURRENT_DESKTOP is absent', () {
      final service = DesktopEnvironmentService(
        environment: const {},
        isLinux: true,
        gsettingsResult: () async => null,
      );

      expect(service.isGnome(), isFalse);
    });
  });

  group('DesktopEnvironmentService.gnomeAccentColor', () {
    test('maps GNOME accent names to hex colors', () async {
      final service = DesktopEnvironmentService(
        environment: const {'XDG_CURRENT_DESKTOP': 'GNOME'},
        isLinux: true,
        gsettingsResult: () async => 'red',
      );

      final color = await service.gnomeAccentColor();

      expect(color, equals(const Color(0xFFE62D42)));
    });

    test('returns null when gsettings returns null', () async {
      final service = DesktopEnvironmentService(
        environment: const {'XDG_CURRENT_DESKTOP': 'GNOME'},
        isLinux: true,
        gsettingsResult: () async => null,
      );

      expect(await service.gnomeAccentColor(), isNull);
    });

    test('returns null on non-Linux', () async {
      final service = DesktopEnvironmentService(
        environment: const {'XDG_CURRENT_DESKTOP': 'GNOME'},
        isLinux: false,
        gsettingsResult: () async => 'blue',
      );

      expect(await service.gnomeAccentColor(), isNull);
    });

    test('returns null for unrecognised accent names', () async {
      final service = DesktopEnvironmentService(
        environment: const {'XDG_CURRENT_DESKTOP': 'GNOME'},
        isLinux: true,
        gsettingsResult: () async => 'fuchsia',
      );

      expect(await service.gnomeAccentColor(), isNull);
    });
  });
}
