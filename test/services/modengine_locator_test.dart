import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:me2_pack_loader/services/modengine_locator.dart';
import 'package:path/path.dart' as p;

void main() {
  group('ModEngineLocator.resolve', () {
    late Directory tempRoot;

    setUp(() {
      tempRoot = Directory.systemTemp.createTempSync('me2_locator_test_');
    });

    tearDown(() {
      if (tempRoot.existsSync()) tempRoot.deleteSync(recursive: true);
    });

    test('copies pre-cache contents into ME2 folder when target is empty',
        () async {
      final appFolder = Directory(p.join(tempRoot.path, 'app'))
        ..createSync(recursive: true);
      final preCache = Directory(p.join(tempRoot.path, 'precache'))
        ..createSync(recursive: true);
      File(p.join(preCache.path, 'modengine2_launcher.exe'))
          .writeAsStringSync('launcher-bytes');
      File(p.join(preCache.path, '.version')).writeAsStringSync('1.0.0');
      Directory(p.join(preCache.path, 'modengine2'))
          .createSync(recursive: true);
      File(p.join(preCache.path, 'modengine2', 'mod.dll'))
          .writeAsStringSync('dll-bytes');

      final locator = ModEngineLocator(
        appFolder: () async => appFolder,
        preCache: () async => preCache,
      );

      final resolved = await locator.resolve();

      expect(p.basename(resolved.path), equals('modengine2'));
      expect(resolved.parent.path, equals(appFolder.path));
      expect(
        File(p.join(resolved.path, 'modengine2_launcher.exe')).readAsStringSync(),
        equals('launcher-bytes'),
      );
      expect(
        File(p.join(resolved.path, '.version')).readAsStringSync(),
        equals('1.0.0'),
      );
      expect(
        File(p.join(resolved.path, 'modengine2', 'mod.dll')).readAsStringSync(),
        equals('dll-bytes'),
      );
    });

    test('leaves ME2 folder untouched when version matches pre-cache',
        () async {
      final appFolder = Directory(p.join(tempRoot.path, 'app'))
        ..createSync(recursive: true);
      final me2Folder = Directory(p.join(appFolder.path, 'modengine2'))
        ..createSync(recursive: true);
      File(p.join(me2Folder.path, '.version')).writeAsStringSync('1.0.0');
      File(p.join(me2Folder.path, 'user-marker.txt'))
          .writeAsStringSync('do not delete me');

      final preCache = Directory(p.join(tempRoot.path, 'precache'))
        ..createSync(recursive: true);
      File(p.join(preCache.path, '.version')).writeAsStringSync('1.0.0');
      File(p.join(preCache.path, 'modengine2_launcher.exe'))
          .writeAsStringSync('NEWER-launcher');

      final locator = ModEngineLocator(
        appFolder: () async => appFolder,
        preCache: () async => preCache,
      );

      await locator.resolve();

      expect(
        File(p.join(me2Folder.path, 'user-marker.txt')).existsSync(),
        isTrue,
        reason: 'marker file must survive — no re-copy when versions match',
      );
      expect(
        File(p.join(me2Folder.path, 'modengine2_launcher.exe')).existsSync(),
        isFalse,
        reason: 'pre-cache must not be copied when versions match',
      );
    });

    test('clears ME2 folder and re-copies when versions differ', () async {
      final appFolder = Directory(p.join(tempRoot.path, 'app'))
        ..createSync(recursive: true);
      final me2Folder = Directory(p.join(appFolder.path, 'modengine2'))
        ..createSync(recursive: true);
      File(p.join(me2Folder.path, '.version')).writeAsStringSync('1.0.0');
      File(p.join(me2Folder.path, 'stale-marker.txt'))
          .writeAsStringSync('left over from 1.0.0');

      final preCache = Directory(p.join(tempRoot.path, 'precache'))
        ..createSync(recursive: true);
      File(p.join(preCache.path, '.version')).writeAsStringSync('1.1.0');
      File(p.join(preCache.path, 'modengine2_launcher.exe'))
          .writeAsStringSync('new-launcher');

      final locator = ModEngineLocator(
        appFolder: () async => appFolder,
        preCache: () async => preCache,
      );

      await locator.resolve();

      expect(
        File(p.join(me2Folder.path, 'stale-marker.txt')).existsSync(),
        isFalse,
        reason: 'stale files must be cleared before re-copying',
      );
      expect(
        File(p.join(me2Folder.path, '.version')).readAsStringSync(),
        equals('1.1.0'),
      );
      expect(
        File(p.join(me2Folder.path, 'modengine2_launcher.exe')).readAsStringSync(),
        equals('new-launcher'),
      );
    });

    test('launcherExe returns modengine2_launcher.exe inside the ME2 folder',
        () async {
      final appFolder = Directory(p.join(tempRoot.path, 'app'))
        ..createSync(recursive: true);

      final locator = ModEngineLocator(
        appFolder: () async => appFolder,
        preCache: () async => null,
      );

      final launcher = await locator.launcherExe();

      expect(p.basename(launcher.path), equals('modengine2_launcher.exe'));
      expect(p.dirname(launcher.path),
          equals(p.join(appFolder.path, 'modengine2')));
    });

    test('throws when pre-cache is not available', () async {
      final appFolder = Directory(p.join(tempRoot.path, 'app'))
        ..createSync(recursive: true);

      final locator = ModEngineLocator(
        appFolder: () async => appFolder,
        preCache: () async => null,
      );

      expect(
        () => locator.resolve(),
        throwsA(
          isA<StateError>().having(
            (e) => e.message.toLowerCase(),
            'message',
            contains('pre-cache'),
          ),
        ),
      );
    });
  });
}
