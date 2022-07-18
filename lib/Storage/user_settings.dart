import 'package:shared_preferences/shared_preferences.dart';

class UserSettings {
  static UserSettings? _instance;
  static late SharedPreferences _sharedPrefs;

  bool _isInappPurchased = false;
  bool _playersSortAscending = false;
  int _pointsAfterReset = 0;
  int _pointsToIncrease = 1;
  bool _canUseHaptic = true;
  bool _canPlaySounds = true;

  void init() async {
    _instance = await _asyncInternal();
  }

  static UserSettings get shared {
    assert(_instance != null, "Call 'init()' function in 'main()'");
    return _instance!;
  }

  static Future<UserSettings> _asyncInternal() async {
    final settings = UserSettings();
    _sharedPrefs = await SharedPreferences.getInstance();
    settings._isInappPurchased = _getBoolForKey(_isInappPurchasedKey) ?? false;
    settings._playersSortAscending = _getBoolForKey(_playersSortAscendingKey) ?? false;
    settings._pointsAfterReset = _getIntForKey(_pointsAfterResetKey) ?? 0;
    settings._pointsToIncrease = _getIntForKey(_pointsToIncreaseKey) ?? 1;
    settings._canUseHaptic = _getBoolForKey(_canUseHapticKey) ?? true;
    settings._canPlaySounds = _getBoolForKey(_canUseSoundsKey) ?? true;
    return settings;
  }

  static const String _isInappPurchasedKey = "_isInappPurchasedKey";
  static const String _playersSortAscendingKey = "playersSortAscending";
  static const String _pointsAfterResetKey = "numberOfPointsAfterReset";
  static const String _pointsToIncreaseKey = "numberOfPointsToIncrease";
  static const String _canUseHapticKey = "canUseHaptic";
  static const String _canUseSoundsKey = "canUseSounds";

  /// get/set preferences for key

  static _setIntForKey(String key, {int? newValue}) {
    if (newValue == null) {
      _sharedPrefs.remove(key);
    } else {
      _sharedPrefs.setInt(key, newValue);
    }
  }

  static int? _getIntForKey(String key) {
    return _sharedPrefs.getInt(key);
  }

  static _setBoolForKey(String key, {bool? newValue}) {
    if (newValue == null) {
      _sharedPrefs.remove(key);
    } else {
      _sharedPrefs.setBool(key, newValue);
    }
  }

  static bool? _getBoolForKey(String key) {
    return _sharedPrefs.getBool(key);
  }

  /// public fields

  bool get isInappPurchased {
    return _isInappPurchased;
  }

  set isInappPurchased(bool newValue) {
    _isInappPurchased = newValue;
    _setBoolForKey(_isInappPurchasedKey, newValue: newValue);
  }

  bool get playersSortAscending {
    return _playersSortAscending;
  }

  set playersSortAscending(bool newValue) {
    _playersSortAscending = newValue;
    _setBoolForKey(_playersSortAscendingKey, newValue: newValue);
  }

  int get pointsAfterReset {
    return _pointsAfterReset;
  }

  set pointsAfterReset(int newValue) {
    _pointsAfterReset = newValue;
    _setIntForKey(_pointsAfterResetKey, newValue: newValue);
  }

  int get pointsToIncrease {
    return _pointsToIncrease;
  }

  set pointsToIncrease(int newValue) {
    _pointsToIncrease = newValue;
    _setIntForKey(_pointsToIncreaseKey, newValue: newValue);
  }

  bool get canUseHaptic {
    return _canUseHaptic;
  }

  set canUseHaptic(newValue) {
    _canUseHaptic = newValue;
    _setBoolForKey(_canUseHapticKey, newValue: newValue);
  }

  bool get canPlaySounds {
    return _canPlaySounds;
  }

  set canPlaySounds(newValue) {
    _canPlaySounds = newValue;
    _setBoolForKey(_canUseSoundsKey, newValue: newValue);
  }
}
