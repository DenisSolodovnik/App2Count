import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:random_color/random_color.dart';

import 'package:scorekeeper/Storage/player.dart';
import 'package:scorekeeper/Storage/user_settings.dart';
import 'package:scorekeeper/UserInterface/Purchases/purchase_manager.dart';
import 'package:scorekeeper/UserInterface/app_colors.dart';
import 'package:scorekeeper/UserInterface/screens_manager.dart';
import 'package:scorekeeper/UserInterface/PlayersScreen/player_edit_dialog.dart';
import 'package:scorekeeper/UserInterface/Settings/settings_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:scorekeeper/UserInterface/sound_manager.dart';
import 'package:scorekeeper/UserInterface/universal_ui_manager.dart';
import 'package:uuid/uuid.dart';

import '../app_feedback_haptic.dart';
import '../widget_keys.dart';
import 'player_cell.dart';
import 'bloc/bloc.dart';

class PlayersScreen extends StatefulWidget {
  const PlayersScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PlayersScreenState();
  }
}

class _PlayersScreenState extends State<PlayersScreen> with PlayerEditDialogDelegate, SingleTickerProviderStateMixin {
  Map<int, Key?> cellsKeys = <int, Key?>{};
  late PlayersListBloc _bloc;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  AnimatedListState? get _animatedList => _listKey.currentState;

  bool _showScoreScreen = false;

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of<PlayersListBloc>(context);

    SoundManager().loadSounds(context);
    Future.delayed(const Duration(seconds: 1)).then((value) => _bloc.add(LoadPlayers()));
  }

  @override
  void dispose() {
    SoundManager().dispose();
    super.dispose();
  }

  AppLocalizations intl() {
    return AppLocalizations.of(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PlayersListBloc, PlayersListState>(
      listener: (context, state) {
        if (state is PlayersListStateLoaded) {
          for (int i = 0; i < state.players.length; i++) {
            _animatedList?.insertItem(i);
          }
        }
        if (state is PlayersListStateRemoved) {
          var key = cellsKeys[state.index];
          cellsKeys[state.index] = null;
          cellsKeys.forEach((key, value) {
            if (key > state.index) {
              SoundManager().playSound(SoundType.playerRemove);
              var newKey = cellsKeys[key];
              cellsKeys[key--] = newKey;
              cellsKeys[key] = null;
            }
          });
          _animatedList?.removeItem(
            state.index,
            (context, animation) {
              return SizeTransition(
                sizeFactor: animation,
                child: PlayerCell(
                  state.player,
                  state.index,
                  key: key,
                ),
              );
            },
          );
        }
        if (state is PlayersListStateAdded) {
          _animatedList?.insertItem(state.index);
        }
      },
      child: BlocBuilder<PlayersListBloc, PlayersListState>(
        builder: (context, state) {
          if (state is PlayersListStateLoaded) {
            return _buildView();
          }
          if (state is PlayersListStateLoading) {
            return _buildLoadView();
          }
          return _buildView();
        },
      ),
    );
  }

  @override
  void didUpdatePlayer(Player player) {
    _bloc.add(EditPlayer(player));
  }

  @override
  void requestToRemovePlayer() {}

  _resetScoresOfAllPlayers() {
    try {
      _bloc.add(ResetGame(UserSettings.shared.pointsAfterReset));
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Topbar (AppBar + it's actions)

  AppBar _topbar() {
    return AppBar(
      backgroundColor: AppColors.backgroundColor,
      elevation: 0,
      title: Row(
        children: [
          Container(
            height: 44,
            width: 84,
            alignment: Alignment.centerLeft,
            child: SvgPicture.asset('assets/logo.svg'),
          ),
          const Expanded(child: SizedBox()),
          IconButton(
            key: const Key(ButtonKeys.settings),
            icon: SvgPicture.asset('assets/settings.svg'),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onPressed: () {
              SoundManager().playSound(SoundType.tap);
              AppFeedbackHaptic.light();
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
            },
          ),
          IconButton(
            icon: SvgPicture.asset('assets/sort.svg'),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onPressed: () {
              SoundManager().playSound(SoundType.tap);
              AppFeedbackHaptic.light();
              _bloc.add(const InversePlayersSorting());
            },
          ),
          IconButton(
            key: const Key(ButtonKeys.resetScores),
            icon: SvgPicture.asset('assets/reset_scores.svg'),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onPressed: () {
              SoundManager().playSound(SoundType.save);
              AppFeedbackHaptic.light();
              _resetScoresOfAllPlayers();
            },
          ),
        ],
      ),
      bottom: const PreferredSize(child: SizedBox(), preferredSize: Size.fromHeight(16)),
    );
  }

  Widget _bottomAddButton() {
    return Container(
      color: AppColors.gray80,
      child: SafeArea(
        child: TextButton.icon(
          onPressed: () {
            SoundManager().playSound(SoundType.playerAdd);
            AppFeedbackHaptic.light();
            _addNewPlayerButtonPressed();
          },
          icon: SvgPicture.asset('assets/user_add.svg'),
          label: Text(
            intl().addPlayerButtonText,
            style: const TextStyle(fontFamily: 'Montserrat', fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white),
          ),
        ),
      ),
    );
  }

  /// Other Widgets
  Widget _buildLoadView() {
    return Scaffold(
      appBar: _topbar(),
      body: Container(
        alignment: Alignment.center,
        child: SizedBox(height: 60, width: 60, child: UniversalUIManager().activityIndicator()),
      ),
    );
  }

  Widget _buildView() {
    return Stack(
      children: [
        Scaffold(
            key: const Key(ScreenKeys.playersListScreen),
            appBar: _topbar(),
            body: Container(
              decoration: const BoxDecoration(color: AppColors.backgroundColor),
              child: Listener(
                onPointerMove: (opm) {
                  FocusScope.of(context).requestFocus(FocusNode());
                  cellsKeys.forEach((key, value) {
                    if (value is GlobalKey<PlayerCellState>) {
                      value.currentState?.resetFocus();
                    }
                  });
                  _bloc.add(const StartDelayForPlayersSorting());
                },
                child: _bloc.players.isNotEmpty ? _buildList() : _buildEmptyView(),
              ),
            ),
            bottomNavigationBar: _bottomAddButton()),
        if (_showScoreScreen)
          Listener(
            onPointerUp: (event) {
              _showScoreScreen = false;
              setState(() {});
            },
            child: ConstrainedBox(
              constraints: const BoxConstraints.expand(),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(color: Colors.black54),
              ),
            ),
          )
      ],
    );
  }

  Widget _buildEmptyView() {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          intl().emptyPlayersListTitle,
          style: const TextStyle(color: Colors.grey, fontSize: 40),
          textAlign: TextAlign.center,
        ),
        const SizedBox(
          height: 32,
        ),
        const SizedBox(
            width: 150,
            height: 150,
            child: Image(
              image: AssetImage('assets/cards_outline.png'),
            )),
      ],
    ));
  }

  Widget _buildList() {
    return SafeArea(
      child: AnimatedList(
        initialItemCount: _bloc.players.length,
        key: _listKey,
        itemBuilder: (context, index, animation) {
          var key = GlobalKey<PlayerCellState>();
          if (cellsKeys[index] == null) {
            cellsKeys[index] = key;
          }
          var cell = PlayerCell(_bloc.players[index], index, key: cellsKeys[index]);
          return SizeTransition(
            sizeFactor: animation,
            child: cell,
          );
        },
      ),
    );
  }

  /// Add new player
  void _addNewPlayerButtonPressed() {
    if (_bloc.players.length > 4) {
      var isBought = PurchaseManager().isInappPurchased(any: true);
      if (!isBought) {
        ScreensManager().showSubscriptionScreen(context);
        return;
      }
    }

    Player player;
    player = Player(
      identifier: const Uuid().v4(),
      points: UserSettings.shared.pointsAfterReset,
      name: intl().defaultPlayerName + (_bloc.players.length + 1).toString(),
      colorValue: RandomColor().randomColor().value,
    );
    _bloc.add(AddPlayer(player));
    // didUpdatePlayer(player);
  }
}
