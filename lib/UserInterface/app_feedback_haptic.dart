import 'package:flutter/services.dart';
import 'package:scorekeeper/Storage/user_settings.dart';

class AppFeedbackHaptic {
  static void light() {
    if (UserSettings.shared.canUseHaptic) {
      HapticFeedback.lightImpact();
    }
  }
}
