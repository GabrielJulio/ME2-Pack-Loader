import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:me2_pack_loader/bloc/config/config_bloc.dart';
import 'package:me2_pack_loader/bloc/config/config_event.dart';
import 'package:me2_pack_loader/bloc/config/config_state.dart';
import 'package:me2_pack_loader/services/config_service.dart';
import 'package:me2_pack_loader/services/game_folder_initializer.dart';
import 'package:path/path.dart' as p;

void main() {
  group('ConfigBloc', () {
    late Directory tempRoot;

    setUp(() async {
      tempRoot = Directory.systemTemp.createTempSync('config_bloc_test_');
      await GameFolderInitializer().initialize(tempRoot);
    });

    tearDown(() {
      if (tempRoot.existsSync()) tempRoot.deleteSync(recursive: true);
    });

    test('loads the most-recent pack and exposes its slug', () async {
      final bloc = ConfigBloc(configService: ConfigService());

      bloc.add(ConfigLoadRequested(tempRoot));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<ConfigLoading>(),
          isA<ConfigLoaded>()
              .having((s) => s.packSlug, 'packSlug', 'default')
              .having((s) => s.config.mods, 'mods', isNotEmpty),
        ]),
      );
      await bloc.close();
    });

    test('toggling a mod writes to <slug>.toml AND config.toml', () async {
      final bloc = ConfigBloc(configService: ConfigService());
      bloc.add(ConfigLoadRequested(tempRoot));
      await expectLater(
        bloc.stream,
        emitsInOrder([isA<ConfigLoading>(), isA<ConfigLoaded>()]),
      );

      bloc.add(ModToggled(0));
      await expectLater(bloc.stream, emits(isA<ConfigLoaded>()));

      final defaultFile =
          File(p.join(tempRoot.path, 'default.toml')).readAsStringSync();
      final configFile =
          File(p.join(tempRoot.path, 'config.toml')).readAsStringSync();

      expect(defaultFile, contains('enabled = false'));
      expect(configFile, equals(defaultFile),
          reason: 'config.toml mirrors the active pack');

      await bloc.close();
    });
  });
}
