import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:me2_pack_loader/services/pre_cache_finder.dart';
import 'package:path/path.dart' as p;

void main() {
  group('PreCacheFinder.find', () {
    late Directory tempRoot;

    setUp(() {
      tempRoot = Directory.systemTemp.createTempSync('precache_finder_test_');
    });

    tearDown(() {
      if (tempRoot.existsSync()) tempRoot.deleteSync(recursive: true);
    });

    test('returns ME2_BUNDLE_DIR override when it points at an existing dir',
        () async {
      final bundle = Directory(p.join(tempRoot.path, 'vendor', 'modengine2'))
        ..createSync(recursive: true);

      final finder = PreCacheFinder(
        bundleDirOverride: bundle.path,
        appDir: null,
        executablePath: null,
        isLinux: true,
        isWindows: false,
      );

      final result = await finder.find();

      expect(result?.path, equals(bundle.path));
    });

    test('on Linux, returns APPDIR/usr/share/modengine2 when it exists',
        () async {
      final appDir = Directory(p.join(tempRoot.path, 'AppDir'))
        ..createSync(recursive: true);
      final bundle = Directory(p.join(appDir.path, 'usr', 'share', 'modengine2'))
        ..createSync(recursive: true);

      final finder = PreCacheFinder(
        bundleDirOverride: null,
        appDir: appDir.path,
        executablePath: null,
        isLinux: true,
        isWindows: false,
      );

      final result = await finder.find();

      expect(result?.path, equals(bundle.path));
    });

    test('on Windows, returns modengine2 next to the executable when it exists',
        () async {
      final installDir = Directory(p.join(tempRoot.path, 'Program Files', 'me2'))
        ..createSync(recursive: true);
      final exe = File(p.join(installDir.path, 'me2_pack_loader.exe'))
        ..writeAsStringSync('stub');
      final bundle = Directory(p.join(installDir.path, 'modengine2'))
        ..createSync(recursive: true);

      final finder = PreCacheFinder(
        bundleDirOverride: null,
        appDir: null,
        executablePath: exe.path,
        isLinux: false,
        isWindows: true,
      );

      final result = await finder.find();

      expect(result?.path, equals(bundle.path));
    });

    test('ME2_BUNDLE_DIR wins over APPDIR-based discovery', () async {
      final overrideBundle = Directory(p.join(tempRoot.path, 'override'))
        ..createSync(recursive: true);
      final appDir = Directory(p.join(tempRoot.path, 'AppDir'))
        ..createSync(recursive: true);
      Directory(p.join(appDir.path, 'usr', 'share', 'modengine2'))
          .createSync(recursive: true);

      final finder = PreCacheFinder(
        bundleDirOverride: overrideBundle.path,
        appDir: appDir.path,
        executablePath: null,
        isLinux: true,
        isWindows: false,
      );

      final result = await finder.find();

      expect(result?.path, equals(overrideBundle.path));
    });

    test('ignores ME2_BUNDLE_DIR override when the path does not exist',
        () async {
      final missing = p.join(tempRoot.path, 'does-not-exist');

      final finder = PreCacheFinder(
        bundleDirOverride: missing,
        appDir: null,
        executablePath: null,
        isLinux: true,
        isWindows: false,
      );

      final result = await finder.find();

      expect(result, isNull);
    });
  });
}
