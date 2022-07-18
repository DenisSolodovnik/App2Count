import 'package:equatable/equatable.dart';
import 'package:scorekeeper/Storage/player.dart';

abstract class PlayersListState extends Equatable {
  const PlayersListState();
}

class PlayersListStateInitial extends PlayersListState {
  @override
  List<Object> get props => [];
}

class PlayersListStateLoading extends PlayersListState {
  @override
  List<Object> get props => [];
}

class PlayersListStateLoaded extends PlayersListState {
  final List<Player> players;

  const PlayersListStateLoaded(this.players);
  @override
  List<Object> get props => [players];
}

class PlayersListStateAdded extends PlayersListState {
  final int index;
  final Player player;
  const PlayersListStateAdded(this.index, this.player);
  @override
  List<Object> get props => [index, player];
}

class PlayersListStateRemoved extends PlayersListState {
  final int index;
  final Player player;
  const PlayersListStateRemoved(this.index, this.player);
  @override
  List<Object> get props => [index, player];
}

class PlayersUpdated extends PlayersListState {
  final Player editedPlayer;
  final List<Player> players;
  const PlayersUpdated(this.players, this.editedPlayer);

  @override
  List<Object> get props => [players, editedPlayer];
}
