import "dart:async";

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:scorekeeper/Storage/player.dart';
import 'package:scorekeeper/Storage/user_settings.dart';
import 'package:scorekeeper/UserInterface/app_colors.dart';
import 'package:scorekeeper/UserInterface/PlayersScreen/player_edit_dialog.dart';
import 'package:scorekeeper/UserInterface/PlayersScreen/long_tap_button.dart';
import 'package:scorekeeper/UserInterface/app_feedback_haptic.dart';
import 'package:scorekeeper/UserInterface/screens_manager.dart';
import 'package:scorekeeper/UserInterface/sound_manager.dart';
import 'package:scorekeeper/UserInterface/widget_keys.dart';
import 'bloc/bloc.dart';

class PlayerCell extends StatefulWidget {
  final Player player;
  final int position;

  const PlayerCell(this.player, this.position, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return PlayerCellState();
  }
}

const _timerCanBeUsed = false;
const _timerDuration = 2; // in seconds
const double _iconSize = 50;
const double _cellHeight = 80;
const double _buttonHeight = 64;

class PlayerCellState extends State<PlayerCell> with PlayerEditDialogDelegate, TickerProviderStateMixin {
  PlayerCellState() : super();

  final TextEditingController _scoreTextController = TextEditingController();
  // final FocusNode _scoreEditFocusNode = FocusNode();
  Timer? _pointsUpdateTimer;

  PlayersListBloc bloc() {
    return BlocProvider.of<PlayersListBloc>(context);
  }

  @override
  void initState() {
    super.initState();
    updateScoreField();
  }

  void _updateScore() {
    try {
      var score = int.parse(_scoreTextController.text);
      var pointsDelta = score - widget.player.points;
      bloc().add(EditPlayer(Player.from(widget.player, pointsDelta: pointsDelta)));
    } catch (e) {
      updateScoreField();
    }
  }

  void _startPlayerEdit() {
    try {
      var score = int.parse(_scoreTextController.text);
      var pointsDelta = score - widget.player.points;
      bloc().add(EditStarted(Player.from(widget.player, pointsDelta: pointsDelta)));
    } catch (e) {
      updateScoreField();
    }
  }

  @override
  Widget build(BuildContext context) {
    updateScoreField();
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        SoundManager().playSound(SoundType.tap);
        AppFeedbackHaptic.light();
        _startPlayerEdit();

        ScreensManager().showPlayerEditDialog(
          context: context,
          player: widget.player,
          delegate: this,
        );
      },
      child: Container(
        key: Key(WidgetKeys.playerCell + widget.player.name + widget.position.toString()),
        color: AppColors.backgroundItemColor,
        height: _cellHeight + 2,
        child: _buildAllWidget(),
      ),
    );
  }

  void updateScoreField() {
    var text = widget.player.totalScore().toString();
    _scoreTextController.text = text;
    _scoreTextController.selection = TextSelection.fromPosition(TextPosition(offset: text.length));
  }

  Widget _buildAllWidget() {
    return Column(children: [
      Row(
        children: [
          const SizedBox(width: 16, height: _cellHeight),
          Expanded(
              child: Column(
            children: [
              _titleLabel(),
              _pointsLabel(),
            ],
          )),
          const SizedBox(width: 8),
          _buttonDecrease(AppColors.buttonColor),
          const SizedBox(width: 8),
          _buttonIncrease(AppColors.buttonColor),
          const SizedBox(width: 16),
        ],
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
      ),
      Container(
        height: 2,
        color: AppColors.backgroundColor,
      )
    ]);
  }

  Widget _titleLabel() {
    return Column(
      children: [
        const SizedBox(height: 8),
        Container(
          height: 22,
          alignment: Alignment.centerLeft,
          child: Text(
            widget.player.name,
            overflow: TextOverflow.clip,
            softWrap: false,
            textAlign: TextAlign.left,
            style: const TextStyle(fontFamily: 'Montserrat', fontSize: 19, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

// GoogleFonts.montserrat(textStyle: const TextStyle(fontSize: 19, fontWeight: FontWeight.w500))
  Widget _pointsLabel() {
    final player = widget.player;
    return Column(
      children: [
        Row(
          children: [
            CircleAvatar(backgroundColor: player.color, radius: 12),
            Expanded(
                child: Text(
              player.pointsDelta == 0 ? '' : player.scoreDeltaString(),
              textAlign: TextAlign.center,
              style: GoogleFonts.oswald(
                height: 1,
                fontSize: 30,
                color: AppColors.palyerDeltaColor,
              ),
            )),
            const SizedBox(width: 17),
            Text(
              player.scoreString(),
              style: GoogleFonts.oswald(
                height: 1,
                fontSize: 45,
                fontWeight: FontWeight.w500,
                color: AppColors.playerNameColor,
              ),
            ),
            const SizedBox(width: 17),
          ],
        ),
      ],
    );
  }

  Widget _buttonDecrease(Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        LongTapButton(
          key: Key(ButtonKeys.subtractPoints + widget.player.name + widget.position.toString()),
          icon: SvgPicture.asset('assets/icon_minus.svg'),
          iconColor: AppColors.gray80,
          size: _buttonHeight,
          cornerRadius: 17,
          color: color,
          fireCallback: (duration, times) {
            SoundManager().playSound(SoundType.scoreDown);
            AppFeedbackHaptic.light();
            _updateScore();
            _scoreDecrease();
          },
        ),
      ],
    );
  }

  Widget _buttonIncrease(Color color) {
    return LongTapButton(
      key: Key(ButtonKeys.addPoints + widget.player.name + widget.position.toString()),
      icon: SvgPicture.asset('assets/icon_plus.svg'),
      iconSize: _iconSize,
      iconColor: AppColors.gray80,
      size: _buttonHeight,
      cornerRadius: 17,
      color: color,
      fireCallback: (duration, times) {
        SoundManager().playSound(SoundType.scoreUp);
        AppFeedbackHaptic.light();
        _updateScore();
        _scoreIncrease();
      },
    );
  }

  void resetFocus() {
    setState(() {});
  }

  void _scoreIncrease() {
    _scoreChangeBy(UserSettings.shared.pointsToIncrease);
  }

  void _scoreDecrease() {
    _scoreChangeBy(-UserSettings.shared.pointsToIncrease);
  }

  void _scoreChangeBy(int delta) {
    _launchPointsUpdateTimer();
    var player = Player.from(widget.player, pointsDelta: widget.player.pointsDelta + delta);
    bloc().add(EditPlayer(player));
  }

  @override
  void didUpdatePlayer(Player player) {
    bloc().add(EditPlayer(player));
  }

  @override
  void requestToRemovePlayer() {
    bloc().add(RemovePlayer(widget.player));
  }

  /// Points Update Timer
  void _launchPointsUpdateTimer() {
    if (!_timerCanBeUsed) {
      return;
    }
    _pointsUpdateTimer?.cancel();
    _pointsUpdateTimer = Timer(const Duration(seconds: _timerDuration), _updatePointsAfterTimerFired);
  }

  void _updatePointsAfterTimerFired() {
    final totalPoints = widget.player.points + widget.player.pointsDelta;
    var player = Player.from(widget.player, points: totalPoints, pointsDelta: 0);
    bloc().add(EditPlayer(player));
  }
}
