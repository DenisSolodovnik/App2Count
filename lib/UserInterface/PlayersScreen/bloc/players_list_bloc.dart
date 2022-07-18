import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:scorekeeper/Storage/data_storage.dart';
import 'package:scorekeeper/Storage/player.dart';
import 'package:scorekeeper/Storage/user_settings.dart';
import './bloc.dart';

class PlayersListBloc extends Bloc<PlayersListEvent, PlayersListState> {
  List<Player> players = [];
  late bool sortAscending = UserSettings.shared.playersSortAscending;
  Timer? _recalculatePointsTimer;

  PlayersListBloc() : super(PlayersListStateInitial());

  @override
  Stream<PlayersListState> mapEventToState(
    PlayersListEvent event,
  ) async* {
    if (event is LoadPlayers) {
      yield* _loadPlayers(event);
    } else if (event is AddPlayer) {
      yield PlayersListStateInitial();
      yield* _addPlayer(event);
    } else if (event is EditPlayer) {
      yield* _editPlayer(event);
    } else if (event is ResetGame) {
      yield PlayersListStateInitial();
      yield* _resetGame(event);
    } else if (event is RemovePlayer) {
      yield PlayersListStateInitial();
      yield* _removePlayer(event);
    } else if (event is InversePlayersSorting) {
      yield PlayersListStateInitial();
      yield* _inversePlayersSorting(event);
    } else if (event is EditStarted) {
      _recalculatePointsTimer?.cancel();
    } else if (event is StartDelayForPlayersSorting) {
      _restartTimerForSortingPlayers();
    } else if (event is SortPlayersAnimated) {
      yield PlayersListStateInitial();
      yield* _sortPlayersAndAnimate(event);
    }
  }

  int _findInsertionPosition(Player player, List<Player> playersList, {int? currentIndex}) {
    int index = 0;
    if (currentIndex != null) {
      if (currentIndex < playersList.length && playersList[currentIndex].points == player.points) {
        return currentIndex;
      }
    }
    for (final elem in playersList) {
      var condition = sortAscending ? elem.points <= player.points : elem.points >= player.points;
      if (condition) {
        index++;
      } else {
        break;
      }
    }
    return index;
  }

  void _sortPlayers(List<Player> players) {
    if (sortAscending) {
      players.sort((a, b) => a.points.compareTo(b.points));
    } else {
      players.sort((a, b) => b.points.compareTo(a.points));
    }
  }

  Stream<PlayersListState> _editPlayer(EditPlayer event) async* {
    var database = await App2scoreDatabase.shared();
    await database.insertPlayer(event.player);
    var index = players.indexWhere((element) => element.identifier == event.player.identifier);
    players[index] = event.player;
    yield PlayersListStateInitial();
    yield PlayersUpdated(players, event.player);
    _restartTimerForSortingPlayers();
  }

  Stream<PlayersListState> _resetGame(ResetGame event) async* {
    List<Player> resetPlayers = [];
    for (var player in players) {
      var resetPlayer = Player.from(player, points: event.points, pointsDelta: 0);
      resetPlayers.add(resetPlayer);
    }
    final database = await App2scoreDatabase.shared();
    database.insertPlayers(resetPlayers);
    players = resetPlayers;
    yield PlayersUpdated(players, players.first);
  }

  Stream<PlayersListState> _removePlayer(RemovePlayer event) async* {
    var database = await App2scoreDatabase.shared();
    await database.removePlayer(event.player);
    var index = players.indexOf(event.player);
    var removedPlayer = players.removeAt(index);

    yield PlayersListStateRemoved(index, removedPlayer);
  }

  Stream<PlayersListState> _addPlayer(AddPlayer event) async* {
    var database = await App2scoreDatabase.shared();
    await database.insertPlayer(event.player);
    var insertIndex = _findInsertionPosition(event.player, players);
    players.insert(insertIndex, event.player);
    yield PlayersListStateAdded(insertIndex, event.player);
  }

  Stream<PlayersListState> _loadPlayers(LoadPlayers event) async* {
    yield PlayersListStateLoading();
    var database = await App2scoreDatabase.shared();
    players = await database.getPlayers();
    _sortPlayers(players);
    yield PlayersListStateLoaded(players);
  }

  Stream<PlayersListState> _inversePlayersSorting(InversePlayersSorting event) async* {
    List<Player> resortedPlayers = [];
    resortedPlayers.addAll(players);
    sortAscending = !sortAscending;
    _sortPlayers(resortedPlayers);
    for (var player in resortedPlayers) {
      add(RemovePlayer(player));
      add(AddPlayer(player));
    }
  }

  Stream<PlayersListState> _sortPlayersAndAnimate(SortPlayersAnimated event) async* {
    List<String> beforeSorting = players.map((player) => player.identifier).toList();
    List<Player> resortedPlayers = [];
    resortedPlayers.addAll(players);
    _sortPlayers(resortedPlayers);
    for (var player in resortedPlayers) {
      var indexBefore = beforeSorting.indexOf(player.identifier);
      var indexAfter = resortedPlayers.indexWhere((p) => p.identifier == player.identifier);
      if (indexAfter != indexBefore) {
        add(RemovePlayer(player));
        add(AddPlayer(player));
      }
    }
  }

  void _restartTimerForSortingPlayers() {
    _recalculatePointsTimer?.cancel();
    _recalculatePointsTimer = Timer(const Duration(seconds: 2), _applyDeltaAndAnimateSortingPlayers);
  }

  void _applyDeltaToPlayers() {
    for (var player in players) {
      if (player.pointsDelta != 0) {
        var index = players.indexWhere((element) => element.identifier == player.identifier);
        var scoreAddedPlayer = Player.from(player, pointsDelta: 0, points: player.points + player.pointsDelta);
        players[index] = scoreAddedPlayer;
      }
    }
  }

  void _applyDeltaAndAnimateSortingPlayers() {
    _applyDeltaToPlayers();
    add(const SortPlayersAnimated());
  }
}
