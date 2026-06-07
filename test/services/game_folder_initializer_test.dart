import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:me2_pack_loader/services/game_folder_initializer.dart';
import 'package:path/path.dart' as p;

void main() {
  group('GameFolderInitializer.initialize', () {
    late Directory tempRoot;

    setUp(() {
      tempRoot = Directory.systemTemp.createTempSync('gfi_test_');
    });

    tearDown(() {
      if (tempRoot.existsSync()) tempRoot.deleteSync(recursive: true);
    });

    test(
        'creates default.toml and mirrors it to config.toml when the folder is '
        'empty', () async {
      await GameFolderInitializer().initialize(tempRoot);

      final defaultFile = File(p.join(tempRoot.path, 'default.toml'));
      final configFile = File(p.join(tempRoot.path, 'config.toml'));

      expect(defaultFile.existsSync(), isTrue);
      expect(configFile.existsSync(), isTrue);
      expect(configFile.readAsStringSync(),
          equals(defaultFile.readAsStringSync()));
      expect(defaultFile.readAsStringSync(), contains('[extension.mod_loader]'));
    });

    test('is a no-op when default.toml + config.toml already exist', () async {
      File(p.join(tempRoot.path, 'default.toml')).writeAsStringSync('# kept');
      File(p.join(tempRoot.path, 'config.toml')).writeAsStringSync('# kept');

      await GameFolderInitializer().initialize(tempRoot);

      expect(
        File(p.join(tempRoot.path, 'default.toml')).readAsStringSync(),
        equals('# kept'),
      );
    });
  });
}
