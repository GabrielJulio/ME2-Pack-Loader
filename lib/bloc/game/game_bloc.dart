import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as p;

import '../../services/data_dir_service.dart';
import '../../services/preferences_service.dart';
import 'game_event.dart';
import 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final PreferencesService preferencesService;
  final DataDirService dataDirService;
  final Future<void> Function(Directory baseDir) initializeGameFolder;

  GameBloc({
    required this.preferencesService,
    required this.dataDirService,
    required this.initializeGameFolder,
  }) : super(GamesInitial()) {
    on<GamesLoadRequested>(_onLoad);
    on<GameActivated>(_onActivate);
    on<GameSelected>(_onSelect);
  }

  Future<void> _onLoad(GamesLoadRequested event, Emitter<GameState> emit) async {
    final activated = await preferencesService.getActivatedGames();
    final current = await preferencesService.getCurrentGame();
    emit(GamesLoaded(activated: activated, current: current));
  }

  Future<void> _onActivate(GameActivated event, Emitter<GameState> emit) async {
    final root = await dataDirService.gamesRoot();
    final dir = Directory(p.join(root.path, event.game.slug));
    final isNewFolder = !dir.existsSync();
    dir.createSync(recursive: true);
    if (isNewFolder) await initializeGameFolder(dir);

    final current = state;
    final activated = {
      if (current is GamesLoaded) ...current.activated,
      event.game,
    };
    await preferencesService.setActivatedGames(activated);
    await preferencesService.setCurrentGame(event.game);
    emit(GamesLoaded(activated: activated, current: event.game));
  }

  Future<void> _onSelect(GameSelected event, Emitter<GameState> emit) async {
    final current = state;
    if (current is! GamesLoaded) return;
    await preferencesService.setCurrentGame(event.game);
    emit(GamesLoaded(activated: current.activated, current: event.game));
  }
}
