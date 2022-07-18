import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_circle_color_picker/flutter_circle_color_picker.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scorekeeper/Storage/player.dart';
import 'package:scorekeeper/UserInterface/universal_ui_manager.dart';
import 'package:scorekeeper/UserInterface/app_colors.dart';
import 'package:scorekeeper/UserInterface/widget_keys.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../sound_manager.dart';
import '../app_feedback_haptic.dart';

abstract class PlayerEditDialogDelegate {
  void didUpdatePlayer(Player player);
  void requestToRemovePlayer();
}

class ColorPickerDialog extends StatefulWidget {
  final Color initialColor;
  const ColorPickerDialog(this.initialColor, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  Color _newColor = Colors.black;
  int _pickerSoundCounter = 3;
  final _playerColorController = CircleColorPickerController();

  @override
  void initState() {
    super.initState();
    _newColor = widget.initialColor;
    _playerColorController.color = _newColor;
  }

  AppLocalizations intl() {
    return AppLocalizations.of(context);
  }

  @override
  Widget build(BuildContext context) {
    final _pickerSize = MediaQuery.of(context).size.width - 64;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(intl().createPlayerSelectColor,
            style: const TextStyle(fontFamily: 'Montserrat', fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.gray80)),
        leading: Container(),
        actions: [
          IconButton(
              icon: SvgPicture.asset('assets/button_close_round.svg'),
              onPressed: () {
                SoundManager().playSound(SoundType.back);
                AppFeedbackHaptic.light();
                Navigator.pop(context, null);
              }),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(
            color: AppColors.gray80,
            height: 0.5,
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(0),
        color: AppColors.backgroundColor,
        alignment: Alignment.center,
        child: CircleColorPicker(
          controller: _playerColorController,
          size: Size(_pickerSize, _pickerSize),
          strokeWidth: 20,
          thumbSize: 60,
          textStyle: const TextStyle(fontFamily: 'Montserrat', fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.gray80),
          onChanged: (color) {
            if (_pickerSoundCounter >= 3) {
              _pickerSoundCounter = 0;
              SoundManager().playSound(SoundType.colorPicker);
              AppFeedbackHaptic.light();
            } else {
              _pickerSoundCounter++;
            }
            setState(() {
              _newColor = color;
            });
          },
        ),
      ),
      bottomNavigationBar: Container(
        color: AppColors.backgroundColor,
        height: 90,
        child: SafeArea(
          minimum: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              TextButton(
                style: ButtonStyle(
                  splashFactory: NoSplash.splashFactory,
                  backgroundColor: MaterialStateProperty.all(AppColors.backgroundItemColor),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(13))),
                  padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 16)),
                  elevation: MaterialStateProperty.all(1),
                ),
                onPressed: () {
                  SoundManager().playSound(SoundType.save);
                  AppFeedbackHaptic.light();
                  Navigator.pop(context, _newColor);
                },
                child: Row(
                  children: [
                    const SizedBox(height: 50),
                    Expanded(
                      child: Text(
                        intl().saveColorButton,
                        style: const TextStyle(fontFamily: 'Montserrat', fontSize: 17, fontWeight: FontWeight.w400, color: AppColors.gray80),
                      ),
                    ),
                    SvgPicture.asset('assets/button_checked_black.svg'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PlayerEditDialog extends StatefulWidget {
  final Player player;
  final PlayerEditDialogDelegate _delegate;
  final double popupWidth = 300;
  final double popupHeight = 340;

  const PlayerEditDialog(this._delegate, {Key? key, required this.player}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PlayerEditDialogState();
  }
}

const double textFieldBorderRadius = 0;
const double colorPickerCircleWidth = 16;
const double colorPickerThimpSize = 50;

class _PlayerEditDialogState extends State<PlayerEditDialog> {
  late Player _changedPlayer;
  final _playerNameController = TextEditingController();
  final _playerPointsController = TextEditingController();

  bool _changed = false;

  @override
  void initState() {
    super.initState();
    final oldPlayer = widget.player;
    _playerNameController.text = oldPlayer.name;
    final sumPoints = oldPlayer.points + oldPlayer.pointsDelta;
    _changedPlayer = Player.from(oldPlayer, points: sumPoints, pointsDelta: 0);
    _playerPointsController.text = sumPoints.toString();
  }

  AppLocalizations intl() {
    return AppLocalizations.of(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key(ScreenKeys.playerEditScreen),
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        leadingWidth: 100,
        leading: TextButton.icon(
          icon: SvgPicture.asset('assets/button_back.svg'),
          label: Text(
            intl().backButton,
            style: const TextStyle(fontFamily: 'Montserrat', fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.gray80),
          ),
          style: const ButtonStyle(splashFactory: NoSplash.splashFactory),
          onPressed: () {
            SoundManager().playSound(SoundType.back);
            AppFeedbackHaptic.light();
            _editExit(savePlayer: false);
          },
        ),
        actions: [
          TextButton.icon(
            icon: Text(
              intl().saveButton,
              style: const TextStyle(fontFamily: 'Montserrat', fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.gray80),
            ),
            label: SvgPicture.asset('assets/button_checked_black.svg'),
            style: const ButtonStyle(splashFactory: NoSplash.splashFactory),
            onPressed: () {
              SoundManager().playSound(SoundType.save);
              AppFeedbackHaptic.light();
              FocusScope.of(context).unfocus();
              _editExit();
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          color: AppColors.backgroundColor,
          child: Column(
            children: [
              const SizedBox(height: 25),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      intl().editPlayerDialogTitle,
                      style: GoogleFonts.oswald(fontSize: 59, height: 1, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        intl().colorTitle,
                        style: const TextStyle(fontFamily: 'Montserrat', fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.gray80),
                      ),
                      IconButton(
                        iconSize: 46,
                        icon: CircleAvatar(
                          radius: 23,
                          backgroundColor: AppColors.gray80,
                          child: CircleAvatar(
                            radius: 22,
                            backgroundColor: _changedPlayer.color,
                          ),
                        ),
                        onPressed: () {
                          SoundManager().playSound(SoundType.tap);
                          AppFeedbackHaptic.light();
                          final result = showModalBottomSheet(
                            context: context,
                            builder: (buildContext) => ColorPickerDialog(_changedPlayer.color),
                          );
                          result.then((value) {
                            if (value != null) {
                              _changedPlayer = Player.from(_changedPlayer, colorValue: value.value);
                              setState(() {
                                _changed = true;
                              });
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(width: 6),
                ],
              ),
              const SizedBox(height: 45),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(width: 16),
                  Text(
                    intl().nameTitle,
                    style: const TextStyle(fontFamily: 'Montserrat', fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.gray80),
                  ),
                ],
              ),
              Row(
                children: [
                  const SizedBox(width: 16),
                  Expanded(
                    child: Focus(
                      onFocusChange: (focus) {
                        if (focus && _playerNameController.text.startsWith(intl().defaultPlayerName)) {
                          setState(() {
                            _playerNameController.text = '';
                          });
                        } else if (!focus && _playerNameController.text.isEmpty) {
                          setState(() {
                            _playerNameController.text = widget.player.name;
                          });
                        }
                      },
                      child: TextField(
                        key: const Key(WidgetKeys.playerEditNameTextField),
                        style: GoogleFonts.roboto(fontSize: 17),
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            icon: SvgPicture.asset('assets/button_cross.svg'),
                            onPressed: () {
                              _playerNameController.text = '';
                              setState(() {
                                _changed = true;
                              });
                            },
                          ),
                          focusedBorder: UnderlineInputBorder(
                              borderRadius: BorderRadius.circular(textFieldBorderRadius),
                              borderSide: const BorderSide(color: AppColors.separatorColor, width: 2.0)),
                          enabledBorder: UnderlineInputBorder(
                              borderRadius: BorderRadius.circular(textFieldBorderRadius),
                              borderSide: const BorderSide(color: AppColors.separatorColor, width: 2.0)),
                        ),
                        onChanged: (text) {
                          _changedPlayer = Player.from(_changedPlayer, name: text);
                          setState(() {
                            _changed = true;
                          });
                        },
                        controller: _playerNameController,
                        textAlign: TextAlign.left,
                        scrollPadding: const EdgeInsets.fromLTRB(0, 0, 0, 100),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(width: 16),
                  Text(
                    intl().scoreTitle,
                    style: const TextStyle(fontFamily: 'Montserrat', fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.gray80),
                  ),
                ],
              ),
              Row(
                children: [
                  const SizedBox(width: 16),
                  Expanded(
                    child: Focus(
                      onFocusChange: (focus) {
                        if (!focus) {
                          if (_playerPointsController.text.isEmpty) {
                            _playerPointsController.text = '0';
                          }
                          _playerPointsController.text = int.parse(_playerPointsController.text).toString();
                        }
                      },
                      child: TextField(
                        key: const Key(WidgetKeys.playerEditPointsTextField),
                        style: GoogleFonts.roboto(fontSize: 17),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            icon: SvgPicture.asset('assets/button_cross.svg'),
                            onPressed: () {
                              _playerPointsController.text = '';
                              _changedPlayer = Player.from(_changedPlayer, points: 0);
                              setState(() {
                                _changed = true;
                              });
                            },
                          ),
                          focusedBorder: UnderlineInputBorder(
                              borderRadius: BorderRadius.circular(textFieldBorderRadius),
                              borderSide: const BorderSide(color: AppColors.separatorColor, width: 2.0)),
                          enabledBorder: UnderlineInputBorder(
                              borderRadius: BorderRadius.circular(textFieldBorderRadius),
                              borderSide: const BorderSide(color: AppColors.separatorColor, width: 2.0)),
                        ),
                        onChanged: (text) {
                          var scoreText = text.isEmpty ? '0' : text;
                          _changedPlayer = Player.from(_changedPlayer, points: int.parse(scoreText));
                          setState(() {
                            _changed = true;
                          });
                        },
                        controller: _playerPointsController,
                        textAlign: TextAlign.left,
                        scrollPadding: const EdgeInsets.fromLTRB(0, 0, 0, 100),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 35),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      SoundManager().playSound(SoundType.playerDelete);
                      AppFeedbackHaptic.light();
                      UniversalUIManager().showAlert(
                        context,
                        title: intl().playerDeletionDialogTitle,
                        content: Text(intl().playerDeletionDialogContent),
                        actions: [
                          TextButton(
                            style: const ButtonStyle(splashFactory: NoSplash.splashFactory),
                            child: Text(
                              intl().cancelActionTitle,
                              style: const TextStyle(color: Colors.black),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            style: const ButtonStyle(splashFactory: NoSplash.splashFactory),
                            child: Text(
                              intl().deleteButton,
                              style: const TextStyle(color: Colors.red),
                            ),
                            onPressed: () {
                              _removePlayer();
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                    icon: ColorFiltered(
                      child: SvgPicture.asset('assets/button_close.svg'),
                      colorFilter: const ColorFilter.mode(Colors.red, BlendMode.srcATop),
                    ),
                    label: Text(
                      intl().deleteButton,
                      style: const TextStyle(fontFamily: 'Montserrat', fontSize: 16, fontWeight: FontWeight.w400, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editExit({bool savePlayer = true}) {
    if (!savePlayer) {
      _changedPlayer = Player.from(widget.player, points: _changedPlayer.points, pointsDelta: 0);
    }
    widget._delegate.didUpdatePlayer(_changedPlayer);
    Navigator.of(context).pop();
  }

  void _removePlayer() {
    widget._delegate.requestToRemovePlayer();
    Navigator.of(context).pop();
  }
}
