import 'package:equatable/equatable.dart';
import 'package:scorekeeper/Storage/player.dart';

abstract class PlayersListEvent extends Equatable {
  const PlayersListEvent();
}

class LoadPlayers extends PlayersListEvent {
  @override
  List<Object> get props => [];
}

class AddPlayer extends PlayersListEvent {
  final Player player;

  const AddPlayer(this.player);

  @override
  List<Object> get props => [player];
}

class EditPlayer extends PlayersListEvent {
  final Player player;

  const EditPlayer(this.player);
  @override
  List<Object> get props => [player];
}

class RemovePlayer extends PlayersListEvent {
  final Player player;

  const RemovePlayer(this.player);
  @override
  List<Object> get props => [player];
}

class ResetGame extends PlayersListEvent {
  final int points;
  const ResetGame(this.points);
  @override
  List<Object> get props => [];
}

class InversePlayersSorting extends PlayersListEvent {
  const InversePlayersSorting();
  @override
  List<Object> get props => [];
}

class SortPlayersAnimated extends PlayersListEvent {
  const SortPlayersAnimated();
  @override
  List<Object> get props => [];
}

class EditStarted extends PlayersListEvent {
  const EditStarted(this.player);
  final Player player;
  @override
  List<Object> get props => [];
}

class StartDelayForPlayersSorting extends PlayersListEvent {
  const StartDelayForPlayersSorting();
  @override
  List<Object> get props => [];
}
