import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:me2_pack_loader/models/data_dir_status.dart';
import 'package:me2_pack_loader/models/disk_check_result.dart';
import 'package:me2_pack_loader/services/data_dir_service.dart';
import 'package:path/path.dart' as p;

void main() {
  group('DataDirService.probe', () {
    late Directory tempRoot;
    late Directory appFolder;

    setUp(() {
      tempRoot = Directory.systemTemp.createTempSync('data_dir_test_');
      appFolder = Directory(p.join(tempRoot.path, 'app'))
        ..createSync(recursive: true);
    });

    tearDown(() {
      if (tempRoot.existsSync()) tempRoot.deleteSync(recursive: true);
    });

    test('returns DefaultDataDir when pointer.json is absent', () async {
      final service = DataDirService(appFolder: () async => appFolder);

      final status = await service.probe();

      expect(status, isA<DefaultDataDir>());
    });

    test(
        'returns CustomDataDir when pointer.json points at an existing directory',
        () async {
      final customDir = Directory(p.join(tempRoot.path, 'custom'))
        ..createSync(recursive: true);
      File(p.join(appFolder.path, 'pointer.json'))
          .writeAsStringSync('{"dataDir": "${customDir.path}"}');

      final service = DataDirService(appFolder: () async => appFolder);
      final status = await service.probe();

      expect(status, isA<CustomDataDir>());
      expect((status as CustomDataDir).path, equals(customDir.path));
    });

    test('returns MissingDataDir when pointer.json points at a missing path',
        () async {
      final ghostPath = p.join(tempRoot.path, 'gone');
      File(p.join(appFolder.path, 'pointer.json'))
          .writeAsStringSync('{"dataDir": "$ghostPath"}');

      final service = DataDirService(appFolder: () async => appFolder);
      final status = await service.probe();

      expect(status, isA<MissingDataDir>());
      expect((status as MissingDataDir).path, equals(ghostPath));
    });

    test('returns DefaultDataDir when pointer.json has dataDir explicitly null',
        () async {
      File(p.join(appFolder.path, 'pointer.json'))
          .writeAsStringSync('{"dataDir": null}');

      final service = DataDirService(appFolder: () async => appFolder);
      final status = await service.probe();

      expect(status, isA<DefaultDataDir>());
    });
  });

  group('DataDirService.gamesRoot', () {
    late Directory tempRoot;
    late Directory appFolder;

    setUp(() {
      tempRoot = Directory.systemTemp.createTempSync('gamesroot_test_');
      appFolder = Directory(p.join(tempRoot.path, 'app'))
        ..createSync(recursive: true);
    });

    tearDown(() {
      if (tempRoot.existsSync()) tempRoot.deleteSync(recursive: true);
    });

    test('default location resolves to <app folder>/modengine2 and creates it',
        () async {
      final service = DataDirService(appFolder: () async => appFolder);

      final root = await service.gamesRoot();

      expect(root.path, equals(p.join(appFolder.path, 'modengine2')));
      expect(root.existsSync(), isTrue);
    });

    test(
        'custom location resolves to <data dir>/me2_pack_loader/modengine2 '
        'and creates it', () async {
      final customDir = Directory(p.join(tempRoot.path, 'custom'))
        ..createSync(recursive: true);
      File(p.join(appFolder.path, 'pointer.json'))
          .writeAsStringSync('{"dataDir": "${customDir.path}"}');

      final service = DataDirService(appFolder: () async => appFolder);

      final root = await service.gamesRoot();

      expect(
        root.path,
        equals(p.join(customDir.path, 'me2_pack_loader', 'modengine2')),
      );
      expect(root.existsSync(), isTrue);
    });
  });

  group('DataDirService.setDataDir', () {
    late Directory tempRoot;
    late Directory appFolder;

    setUp(() {
      tempRoot = Directory.systemTemp.createTempSync('setdatadir_test_');
      appFolder = Directory(p.join(tempRoot.path, 'app'))
        ..createSync(recursive: true);
    });

    tearDown(() {
      if (tempRoot.existsSync()) tempRoot.deleteSync(recursive: true);
    });

    test('writes the chosen path into pointer.json, observable via probe',
        () async {
      final customDir = Directory(p.join(tempRoot.path, 'pick'))
        ..createSync(recursive: true);
      final service = DataDirService(appFolder: () async => appFolder);

      await service.setDataDir(customDir.path);
      final status = await service.probe();

      expect(status, isA<CustomDataDir>());
      expect((status as CustomDataDir).path, equals(customDir.path));
    });

    test('passing null clears the pointer and reverts to default', () async {
      final customDir = Directory(p.join(tempRoot.path, 'pick'))
        ..createSync(recursive: true);
      final service = DataDirService(appFolder: () async => appFolder);
      await service.setDataDir(customDir.path);

      await service.setDataDir(null);
      final status = await service.probe();

      expect(status, isA<DefaultDataDir>());
    });
  });

  group('DataDirService.directorySize', () {
    late Directory tempRoot;

    setUp(() {
      tempRoot = Directory.systemTemp.createTempSync('dirsize_test_');
    });

    tearDown(() {
      if (tempRoot.existsSync()) tempRoot.deleteSync(recursive: true);
    });

    test('sums all files recursively', () async {
      File(p.join(tempRoot.path, 'a.bin')).writeAsBytesSync(List.filled(100, 0));
      Directory(p.join(tempRoot.path, 'sub')).createSync();
      File(p.join(tempRoot.path, 'sub', 'b.bin'))
          .writeAsBytesSync(List.filled(250, 0));
      Directory(p.join(tempRoot.path, 'sub', 'deep')).createSync();
      File(p.join(tempRoot.path, 'sub', 'deep', 'c.bin'))
          .writeAsBytesSync(List.filled(50, 0));

      final service = DataDirService(appFolder: () async => tempRoot);
      final total = await service.directorySize(tempRoot);

      expect(total, equals(400));
    });

    test('returns 0 for a missing directory', () async {
      final ghost = Directory(p.join(tempRoot.path, 'nope'));
      final service = DataDirService(appFolder: () async => tempRoot);

      expect(await service.directorySize(ghost), equals(0));
    });
  });

  group('DataDirService.checkSpace', () {
    late Directory tempRoot;
    late Directory appFolder;

    setUp(() {
      tempRoot = Directory.systemTemp.createTempSync('checkspace_test_');
      appFolder = Directory(p.join(tempRoot.path, 'app'))
        ..createSync(recursive: true);
    });

    tearDown(() {
      if (tempRoot.existsSync()) tempRoot.deleteSync(recursive: true);
    });

    test(
        'sums current games-root size and compares with free space at '
        'destination', () async {
      final gamesRoot = Directory(p.join(appFolder.path, 'modengine2'))
        ..createSync(recursive: true);
      File(p.join(gamesRoot.path, 'mod.bin'))
          .writeAsBytesSync(List.filled(1024, 0));

      final destination = Directory(p.join(tempRoot.path, 'dest'))
        ..createSync(recursive: true);

      final service = DataDirService(
        appFolder: () async => appFolder,
        freeBytesAt: (path) async => 5_000_000_000,
      );

      final result = await service.checkSpace(destination.path);

      expect(result.neededBytes, equals(1024));
      expect(result.freeBytes, equals(5_000_000_000));
      expect(result.verdict, equals(DiskVerdict.enough));
    });
  });

  group('DataDirService.moveTo', () {
    late Directory tempRoot;
    late Directory appFolder;
    late DataDirService service;

    setUp(() {
      tempRoot = Directory.systemTemp.createTempSync('moveto_test_');
      appFolder = Directory(p.join(tempRoot.path, 'app'))
        ..createSync(recursive: true);
      service = DataDirService(
        appFolder: () async => appFolder,
        freeBytesAt: (_) async => 100_000_000_000,
      );
    });

    tearDown(() {
      if (tempRoot.existsSync()) tempRoot.deleteSync(recursive: true);
    });

    test('default → custom moves the named game folders into the new dir',
        () async {
      final defaultRoot = await service.gamesRoot();
      Directory(p.join(defaultRoot.path, 'dark_souls_3'))
          .createSync(recursive: true);
      File(p.join(defaultRoot.path, 'dark_souls_3', 'config.toml'))
          .writeAsStringSync('# ds3');
      Directory(p.join(defaultRoot.path, 'elden_ring'))
          .createSync(recursive: true);
      File(p.join(defaultRoot.path, 'elden_ring', 'config.toml'))
          .writeAsStringSync('# er');

      final customDir = Directory(p.join(tempRoot.path, 'storage'))
        ..createSync(recursive: true);

      await service.moveTo(
        newDataDir: customDir.path,
        gameFolderSlugs: const ['dark_souls_3', 'elden_ring'],
      );

      final newRoot = await service.gamesRoot();
      expect(newRoot.path,
          equals(p.join(customDir.path, 'me2_pack_loader', 'modengine2')));
      expect(
        File(p.join(newRoot.path, 'dark_souls_3', 'config.toml'))
            .readAsStringSync(),
        equals('# ds3'),
      );
      expect(
        File(p.join(newRoot.path, 'elden_ring', 'config.toml'))
            .readAsStringSync(),
        equals('# er'),
      );
      expect(Directory(p.join(defaultRoot.path, 'dark_souls_3')).existsSync(),
          isFalse);
      expect(Directory(p.join(defaultRoot.path, 'elden_ring')).existsSync(),
          isFalse);
    });
  });
}
