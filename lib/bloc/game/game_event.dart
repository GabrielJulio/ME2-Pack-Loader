import '../../models/game.dart';

abstract class GameEvent {}

class GamesLoadRequested extends GameEvent {}

class GameActivated extends GameEvent {
  final Game game;
  GameActivated(this.game);
}

class GameSelected extends GameEvent {
  final Game game;
  GameSelected(this.game);
}
