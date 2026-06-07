import '../../models/game.dart';

abstract class GameState {}

class GamesInitial extends GameState {}

class GamesLoaded extends GameState {
  final Set<Game> activated;
  final Game? current;
  GamesLoaded({required this.activated, required this.current});
}
