import 'package:flutter/material.dart';
import 'package:scorekeeper/Storage/user_settings.dart';
import 'package:sound_mode/sound_mode.dart';
import 'package:soundpool/soundpool.dart';
import 'package:sound_mode/utils/ringer_mode_statuses.dart';

enum SoundType {
  scoreUp,
  scoreDown,
  playerDelete,
  playerRemove,
  playerAdd,
  tap,
  back,
  save,
  colorPicker,
}

class SoundData {
  int? soundId;
  int? streamId;

  SoundData.fromSoundId(this.soundId);
}

class SoundManager {
  static final SoundManager _singleton = SoundManager._internal();

  factory SoundManager() => _singleton;

  SoundManager._internal();

  bool _isSoundsLoaded = false;

  final _soundPool = Soundpool.fromOptions(
    options: const SoundpoolOptions(
      maxStreams: 10,
      streamType: StreamType.music,
    ),
  );
  final Map<SoundType, SoundData> _sounds = {};

  void loadSounds(BuildContext buildContext) async {
    if (_isSoundsLoaded) {
      return;
    }

    var byteData = await DefaultAssetBundle.of(buildContext).load('assets/sounds/tap.mp3');
    _sounds[SoundType.tap] = SoundData.fromSoundId(await _soundPool.load(byteData));
    byteData = await DefaultAssetBundle.of(buildContext).load('assets/sounds/back.mp3');
    _sounds[SoundType.back] = SoundData.fromSoundId(await _soundPool.load(byteData));
    byteData = await DefaultAssetBundle.of(buildContext).load('assets/sounds/save.mp3');
    _sounds[SoundType.save] = SoundData.fromSoundId(await _soundPool.load(byteData));
    byteData = await DefaultAssetBundle.of(buildContext).load('assets/sounds/score_up.mp3');
    _sounds[SoundType.scoreUp] = SoundData.fromSoundId(await _soundPool.load(byteData));
    byteData = await DefaultAssetBundle.of(buildContext).load('assets/sounds/score_down.mp3');
    _sounds[SoundType.scoreDown] = SoundData.fromSoundId(await _soundPool.load(byteData));
    byteData = await DefaultAssetBundle.of(buildContext).load('assets/sounds/player_add.mp3');
    _sounds[SoundType.playerAdd] = SoundData.fromSoundId(await _soundPool.load(byteData));
    byteData = await DefaultAssetBundle.of(buildContext).load('assets/sounds/player_remove.mp3');
    _sounds[SoundType.playerDelete] = SoundData.fromSoundId(await _soundPool.load(byteData));
    byteData = await DefaultAssetBundle.of(buildContext).load('assets/sounds/player_delete.mp3');
    _sounds[SoundType.playerRemove] = SoundData.fromSoundId(await _soundPool.load(byteData));
    byteData = await DefaultAssetBundle.of(buildContext).load('assets/sounds/color_picker.mp3');
    _sounds[SoundType.colorPicker] = SoundData.fromSoundId(await _soundPool.load(byteData));
    _isSoundsLoaded = true;
  }

  void dispose() {
    _soundPool.release();
  }

  void playSound(SoundType soundType) async {
    if (!UserSettings.shared.canPlaySounds) {
      return;
    }

    final ringerMode = await SoundMode.ringerModeStatus;
    if (ringerMode != RingerModeStatus.normal) {
      return;
    }

    if (_sounds[soundType]?.soundId != null) {
      _sounds[soundType]!.streamId = await _soundPool.play(_sounds[soundType]!.soundId!);
    }
  }
}
