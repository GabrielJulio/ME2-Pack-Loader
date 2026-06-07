import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:me2_pack_loader/services/pack_service.dart';
import 'package:path/path.dart' as p;

void main() {
  group('PackService.list', () {
    late Directory tempRoot;

    setUp(() {
      tempRoot = Directory.systemTemp.createTempSync('pack_service_test_');
    });

    tearDown(() {
      if (tempRoot.existsSync()) tempRoot.deleteSync(recursive: true);
    });

    test('returns empty list when no toml files exist', () async {
      final packs = await PackService().list(tempRoot);
      expect(packs, isEmpty);
    });

    test('lists every *.toml as a pack, excluding config.toml', () async {
      File(p.join(tempRoot.path, 'default.toml')).writeAsStringSync('# d');
      File(p.join(tempRoot.path, 'convergence.toml')).writeAsStringSync('# c');
      File(p.join(tempRoot.path, 'config.toml')).writeAsStringSync('# mirror');
      File(p.join(tempRoot.path, 'README.md')).writeAsStringSync('# md');

      final packs = await PackService().list(tempRoot);

      expect(packs.map((p) => p.slug).toSet(),
          equals({'default', 'convergence'}));
    });

    test('sorts most-recently-modified first', () async {
      final older = File(p.join(tempRoot.path, 'older.toml'))
        ..writeAsStringSync('# old');
      older.setLastModifiedSync(DateTime(2024, 1, 1));

      final newer = File(p.join(tempRoot.path, 'newer.toml'))
        ..writeAsStringSync('# new');
      newer.setLastModifiedSync(DateTime(2024, 6, 1));

      final packs = await PackService().list(tempRoot);

      expect(packs.first.slug, equals('newer'));
      expect(packs[1].slug, equals('older'));
    });
  });

  group('PackService.activate', () {
    late Directory tempRoot;

    setUp(() {
      tempRoot = Directory.systemTemp.createTempSync('pack_activate_test_');
    });

    tearDown(() {
      if (tempRoot.existsSync()) tempRoot.deleteSync(recursive: true);
    });

    test('copies the pack content into config.toml and touches its mtime',
        () async {
      File(p.join(tempRoot.path, 'convergence.toml'))
          .writeAsStringSync('[modengine]\ndebug = false');

      final service = PackService();
      final packs = await service.list(tempRoot);
      final pack = packs.firstWhere((p) => p.slug == 'convergence');

      await service.activate(tempRoot, pack);

      expect(
        File(p.join(tempRoot.path, 'config.toml')).readAsStringSync(),
        equals('[modengine]\ndebug = false'),
      );
    });

    test('activate overwrites any prior config.toml', () async {
      File(p.join(tempRoot.path, 'convergence.toml'))
          .writeAsStringSync('new content');
      File(p.join(tempRoot.path, 'config.toml'))
          .writeAsStringSync('old content');

      final service = PackService();
      final packs = await service.list(tempRoot);
      final pack = packs.firstWhere((p) => p.slug == 'convergence');

      await service.activate(tempRoot, pack);

      expect(
        File(p.join(tempRoot.path, 'config.toml')).readAsStringSync(),
        equals('new content'),
      );
    });
  });

  group('PackService.activeSlug', () {
    late Directory tempRoot;

    setUp(() {
      tempRoot =
          Directory.systemTemp.createTempSync('pack_activeSlug_test_');
    });

    tearDown(() {
      if (tempRoot.existsSync()) tempRoot.deleteSync(recursive: true);
    });

    test('returns the slug whose content matches config.toml', () async {
      File(p.join(tempRoot.path, 'default.toml'))
          .writeAsStringSync('# default');
      File(p.join(tempRoot.path, 'convergence.toml'))
          .writeAsStringSync('# convergence');
      File(p.join(tempRoot.path, 'config.toml'))
          .writeAsStringSync('# convergence');

      final service = PackService();
      expect(await service.activeSlug(tempRoot), equals('convergence'));
    });

    test('returns null when no config.toml exists', () async {
      File(p.join(tempRoot.path, 'default.toml'))
          .writeAsStringSync('# default');

      expect(await PackService().activeSlug(tempRoot), isNull);
    });
  });

  group('PackService.create', () {
    late Directory tempRoot;

    setUp(() {
      tempRoot = Directory.systemTemp.createTempSync('pack_create_test_');
    });

    tearDown(() {
      if (tempRoot.existsSync()) tempRoot.deleteSync(recursive: true);
    });

    test('writes <slug>.toml with the given content', () async {
      await PackService().create(tempRoot, 'convergence', '[modengine]');

      expect(
        File(p.join(tempRoot.path, 'convergence.toml')).readAsStringSync(),
        equals('[modengine]'),
      );
    });

    test('rejects the reserved slug "config"', () async {
      expect(
        () => PackService().create(tempRoot, 'config', ''),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('rejects an already-existing slug', () async {
      await PackService().create(tempRoot, 'default', 'a');

      expect(
        () => PackService().create(tempRoot, 'default', 'b'),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('PackService.delete + rename', () {
    late Directory tempRoot;

    setUp(() {
      tempRoot = Directory.systemTemp.createTempSync('pack_crud_test_');
    });

    tearDown(() {
      if (tempRoot.existsSync()) tempRoot.deleteSync(recursive: true);
    });

    test('delete removes only the named pack file', () async {
      await PackService().create(tempRoot, 'default', 'a');
      await PackService().create(tempRoot, 'convergence', 'b');

      await PackService().delete(tempRoot, 'default');

      expect(
        File(p.join(tempRoot.path, 'default.toml')).existsSync(),
        isFalse,
      );
      expect(
        File(p.join(tempRoot.path, 'convergence.toml')).existsSync(),
        isTrue,
      );
    });

    test('rename moves <old>.toml to <new>.toml preserving content', () async {
      await PackService().create(tempRoot, 'default', 'preserved');

      await PackService().rename(tempRoot, 'default', 'baseline');

      expect(File(p.join(tempRoot.path, 'default.toml')).existsSync(), isFalse);
      expect(
        File(p.join(tempRoot.path, 'baseline.toml')).readAsStringSync(),
        equals('preserved'),
      );
    });

    test('rename rejects if the new slug already exists', () async {
      await PackService().create(tempRoot, 'a', '');
      await PackService().create(tempRoot, 'b', '');

      expect(
        () => PackService().rename(tempRoot, 'a', 'b'),
        throwsA(isA<StateError>()),
      );
    });
  });
}
