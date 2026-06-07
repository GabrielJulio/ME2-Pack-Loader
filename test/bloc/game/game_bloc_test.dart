import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:me2_pack_loader/bloc/game/game_bloc.dart';
import 'package:me2_pack_loader/bloc/game/game_event.dart';
import 'package:me2_pack_loader/bloc/game/game_state.dart';
import 'package:me2_pack_loader/models/game.dart';
import 'package:me2_pack_loader/services/data_dir_service.dart';
import 'package:me2_pack_loader/services/preferences_service.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('GameBloc', () {
    late Directory tempRoot;
    late Directory appFolder;

    setUp(() {
      tempRoot = Directory.systemTemp.createTempSync('game_bloc_test_');
      appFolder = Directory(p.join(tempRoot.path, 'app'))
        ..createSync(recursive: true);
      SharedPreferences.setMockInitialValues({});
    });

    tearDown(() {
      if (tempRoot.existsSync()) tempRoot.deleteSync(recursive: true);
    });

    GameBloc buildBloc({List<Directory>? initializedDirs}) {
      return GameBloc(
        preferencesService: PreferencesService(),
        dataDirService: DataDirService(
          appFolder: () async => appFolder,
          freeBytesAt: (_) async => 100_000_000_000,
        ),
        initializeGameFolder: (dir) async {
          initializedDirs?.add(dir);
        },
      );
    }

    test(
        'on first launch with no activated games, emits GamesLoaded with empty '
        'set and null current', () async {
      final bloc = buildBloc();
      bloc.add(GamesLoadRequested());

      await expectLater(
        bloc.stream,
        emits(isA<GamesLoaded>()
            .having((s) => s.activated, 'activated', isEmpty)
            .having((s) => s.current, 'current', isNull)),
      );

      await bloc.close();
    });

    test(
        'activating a game creates the folder, calls the initializer, persists '
        'and emits with that game in the set and as current', () async {
      final initialized = <Directory>[];
      final bloc = buildBloc(initializedDirs: initialized);
      bloc.add(GamesLoadRequested());
      await expectLater(bloc.stream, emits(isA<GamesLoaded>()));

      bloc.add(GameActivated(Game.darkSouls3));

      await expectLater(
        bloc.stream,
        emits(isA<GamesLoaded>()
            .having((s) => s.activated, 'activated', {Game.darkSouls3})
            .having((s) => s.current, 'current', Game.darkSouls3)),
      );

      final expectedDir =
          Directory(p.join(appFolder.path, 'modengine2', 'dark_souls_3'));
      expect(expectedDir.existsSync(), isTrue);
      expect(initialized.single.path, equals(expectedDir.path));
      expect(
        await PreferencesService().getActivatedGames(),
        equals({Game.darkSouls3}),
      );
      expect(
        await PreferencesService().getCurrentGame(),
        equals(Game.darkSouls3),
      );

      await bloc.close();
    });

    test('GameSelected updates current without re-running the initializer',
        () async {
      final initialized = <Directory>[];
      final bloc = buildBloc(initializedDirs: initialized);
      bloc.add(GamesLoadRequested());
      await expectLater(bloc.stream, emits(isA<GamesLoaded>()));
      bloc.add(GameActivated(Game.darkSouls3));
      await expectLater(bloc.stream, emits(isA<GamesLoaded>()));
      bloc.add(GameActivated(Game.eldenRing));
      await expectLater(bloc.stream, emits(isA<GamesLoaded>()));

      initialized.clear();
      bloc.add(GameSelected(Game.darkSouls3));

      await expectLater(
        bloc.stream,
        emits(isA<GamesLoaded>()
            .having((s) => s.current, 'current', Game.darkSouls3)
            .having((s) => s.activated, 'activated',
                {Game.darkSouls3, Game.eldenRing})),
      );

      expect(initialized, isEmpty);
      await bloc.close();
    });
  });
}
