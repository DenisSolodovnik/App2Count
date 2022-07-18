import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:package_info/package_info.dart';
import 'package:scorekeeper/Storage/user_settings.dart';
import 'package:scorekeeper/UserInterface/universal_ui_manager.dart';
import 'package:scorekeeper/UserInterface/screens_manager.dart';
import 'package:scorekeeper/UserInterface/widget_keys.dart';

import '../sound_manager.dart';
import '../app_feedback_haptic.dart';
import '../app_colors.dart';

final InAppReview inAppReview = InAppReview.instance;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SettingsScreenState();
  }
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _pointsAfterResetTextField = TextEditingController();
  final TextEditingController _pointsToIncreaseTextField = TextEditingController();

  final double _textFieldBorderRadius = 0;

  @override
  void initState() {
    _pointsAfterResetTextField.text = UserSettings.shared.pointsAfterReset.toString();
    _pointsToIncreaseTextField.text = UserSettings.shared.pointsToIncrease.toString();

    super.initState();
  }

  AppLocalizations intl() {
    return AppLocalizations.of(context);
  }

  @override
  Widget build(BuildContext context) {
    final intl = AppLocalizations.of(context);
    return Scaffold(
      key: const Key(ScreenKeys.settingsScreen),
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        leadingWidth: 100,
        leading: TextButton.icon(
          icon: SvgPicture.asset('assets/button_back.svg'),
          label: Text(
            intl.backButton,
            style: const TextStyle(fontFamily: 'Montserrat', fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.gray80),
          ),
          style: const ButtonStyle(splashFactory: NoSplash.splashFactory),
          onPressed: () {
            SoundManager().playSound(SoundType.back);
            AppFeedbackHaptic.light();
            Navigator.of(context).pop();
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Text(
                intl.settingsScreenTitle,
                style: GoogleFonts.oswald(fontSize: 59, fontWeight: FontWeight.w500, color: AppColors.gray80),
              ),
            ],
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            Column(
              children: [
                const SizedBox(height: 41),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(width: 16),
                    Text(
                      intl.settingsPointsAfterResetTitle,
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
                            if (_pointsAfterResetTextField.text.isEmpty) {
                              _pointsAfterResetTextField.text = '0';
                            }
                            _pointsAfterResetTextField.text = int.parse(_pointsAfterResetTextField.text).toString();
                            _setPointsAfterReset(_pointsAfterResetTextField.text);
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
                                _pointsAfterResetTextField.text = '';
                                setState(() {});
                              },
                            ),
                            focusedBorder: UnderlineInputBorder(
                                borderRadius: BorderRadius.circular(_textFieldBorderRadius),
                                borderSide: const BorderSide(color: AppColors.separatorColor, width: 2.0)),
                            enabledBorder: UnderlineInputBorder(
                                borderRadius: BorderRadius.circular(_textFieldBorderRadius),
                                borderSide: const BorderSide(color: AppColors.gray80, width: 2.0)),
                          ),
                          onChanged: (text) {
                            var scoreText = text.isEmpty ? '0' : text;
                            _setPointsAfterReset(scoreText);
                            setState(() {});
                          },
                          controller: _pointsAfterResetTextField,
                          textAlign: TextAlign.left,
                          scrollPadding: const EdgeInsets.fromLTRB(0, 0, 0, 100),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(width: 16),
                    Text(
                      intl.settingsPointsToIncreaseTitle,
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
                            if (_pointsToIncreaseTextField.text.isEmpty || _pointsToIncreaseTextField.text == '0') {
                              _pointsToIncreaseTextField.text = '1';
                            }
                            _pointsToIncreaseTextField.text = int.parse(_pointsToIncreaseTextField.text).toString();
                            _setPointsToAdd(_pointsToIncreaseTextField.text);
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
                                _pointsToIncreaseTextField.text = '';
                                setState(() {});
                              },
                            ),
                            focusedBorder: UnderlineInputBorder(
                                borderRadius: BorderRadius.circular(_textFieldBorderRadius),
                                borderSide: const BorderSide(color: AppColors.separatorColor, width: 2.0)),
                            enabledBorder: UnderlineInputBorder(
                                borderRadius: BorderRadius.circular(_textFieldBorderRadius),
                                borderSide: const BorderSide(color: AppColors.gray80, width: 2.0)),
                          ),
                          onChanged: (text) {
                            var scoreText = text.isEmpty ? '0' : text;
                            _setPointsToAdd(scoreText);
                            setState(() {});
                          },
                          controller: _pointsToIncreaseTextField,
                          textAlign: TextAlign.left,
                          scrollPadding: const EdgeInsets.fromLTRB(0, 0, 0, 100),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6.5),
                Row(
                  children: [
                    const SizedBox(width: 16),
                    Expanded(
                        child: Text(intl.soundOption, style: GoogleFonts.roboto(fontSize: 17, fontWeight: FontWeight.w400, color: AppColors.gray80))),
                    FlutterSwitch(
                      activeColor: AppColors.toggleColor,
                      showOnOff: true,
                      value: UserSettings.shared.canPlaySounds,
                      onToggle: (isOn) {
                        setState(() {
                          UserSettings.shared.canPlaySounds = isOn;
                        });
                      },
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
                const SizedBox(height: 6.5),
                Row(
                  children: [
                    const SizedBox(width: 16),
                    Expanded(child: Container(color: AppColors.gray80, height: 0.5)),
                  ],
                ),
                const SizedBox(height: 6.5),
                Row(
                  children: [
                    const SizedBox(width: 16),
                    Expanded(
                        child:
                            Text(intl.hapticOption, style: GoogleFonts.roboto(fontSize: 17, fontWeight: FontWeight.w400, color: AppColors.gray80))),
                    FlutterSwitch(
                      activeColor: AppColors.toggleColor,
                      showOnOff: true,
                      value: UserSettings.shared.canUseHaptic,
                      onToggle: (isOn) {
                        setState(() {
                          UserSettings.shared.canUseHaptic = isOn;
                        });
                      },
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
                const SizedBox(height: 6.5),
                Row(
                  children: [
                    const SizedBox(width: 16),
                    Expanded(child: Container(color: AppColors.gray80, height: 0.5)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(34, 57, 34, 22),
                  child: Text(
                    intl.subscriptionTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontFamily: 'Montserrat', fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.gray80),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: Container(
                    alignment: Alignment.center,
                    height: 93,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(13),
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          offset: Offset(0.0, 2.0),
                          blurRadius: 2.0,
                        )
                      ],
                    ),
                    child: TextButton(
                      child: Text(
                        intl.purchaseScreenSubscribeTitle,
                        style: const TextStyle(fontFamily: 'Montserrat', fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.gray80),
                      ),
                      style: ButtonStyle(
                        splashFactory: NoSplash.splashFactory,
                        backgroundColor: MaterialStateProperty.all(AppColors.inappButtonColor),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))),
                        padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 16)),
                        elevation: MaterialStateProperty.all(1),
                        fixedSize: MaterialStateProperty.all(const Size(230, 57)),
                      ),
                      onPressed: () => _showSubscribeScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        style: const ButtonStyle(splashFactory: NoSplash.splashFactory),
                        child: Text(
                          intl.rateTheApp,
                          style: const TextStyle(fontFamily: 'Montserrat', fontSize: 17, fontWeight: FontWeight.w400, color: AppColors.linkColor),
                        ),
                        onPressed: () => _askForReview(),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        style: const ButtonStyle(splashFactory: NoSplash.splashFactory),
                        child: Text(
                          intl.aboutApp,
                          style: const TextStyle(fontFamily: 'Montserrat', fontSize: 17, fontWeight: FontWeight.w400, color: AppColors.linkColor),
                        ),
                        onPressed: () => _showAbout(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: Container(color: Colors.black26, height: 1)),
                  ],
                ),
                const SizedBox(height: 16),
                TextButton(
                  style: const ButtonStyle(splashFactory: NoSplash.splashFactory),
                  child: Row(
                    children: [
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          intl.privacyPolicy,
                          style: const TextStyle(fontFamily: 'Montserrat', fontSize: 17, fontWeight: FontWeight.w400, color: AppColors.linkColor),
                        ),
                      ),
                      SvgPicture.asset('assets/arrow_right.svg'),
                      const SizedBox(width: 20),
                    ],
                  ),
                  onPressed: () => _openLink(Uri.parse(intl.purchasePrivacyPolicyLink)),
                ),
                TextButton(
                  style: const ButtonStyle(splashFactory: NoSplash.splashFactory),
                  child: Row(
                    children: [
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          intl.termsOfUse,
                          style: const TextStyle(fontFamily: 'Montserrat', fontSize: 17, fontWeight: FontWeight.w400, color: AppColors.linkColor),
                        ),
                      ),
                      SvgPicture.asset('assets/arrow_right.svg'),
                      const SizedBox(width: 20),
                    ],
                  ),
                  onPressed: () => _openLink(Uri.parse(intl.purchaseTermsOfUseLink)),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 30, 16, 57),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          style: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.gray80),
                          text: intl.agreementText1,
                        ),
                        TextSpan(
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.gray80,
                            decoration: TextDecoration.underline,
                          ),
                          text: intl.agreementText2,
                          recognizer: TapGestureRecognizer()..onTap = () => _openLink(Uri.parse(intl.purchaseTermsOfUseLink)),
                        ),
                        TextSpan(
                          style: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.gray80),
                          text: intl.agreementText3,
                        ),
                        TextSpan(
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.gray80,
                            decoration: TextDecoration.underline,
                          ),
                          text: intl.agreementText4,
                          recognizer: TapGestureRecognizer()..onTap = () => _openLink(Uri.parse(intl.purchasePrivacyPolicyLink)),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _setPointsAfterReset(String points) {
    try {
      var pt = int.parse(points);
      UserSettings.shared.pointsAfterReset = pt;
      debugPrint(UserSettings.shared.pointsAfterReset.toString());
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _setPointsToAdd(String points) {
    try {
      var pt = int.parse(points);
      UserSettings.shared.pointsToIncrease = pt;
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _openLink(Uri link) {
    final browser = ChromeSafariBrowser();

    return browser.open(url: link, options: ChromeSafariBrowserClassOptions(ios: IOSSafariOptions(preferredBarTintColor: Colors.white)));
  }

  void _askForReview() async {
    if (await inAppReview.isAvailable()) {
      // For Android work *only* from GooglePlay!
      inAppReview.requestReview();
    }
  }

  void _showAbout(BuildContext context) async {
    var packageInfo = await PackageInfo.fromPlatform();
    UniversalUIManager().showAlert(
      context,
      title: 'v.' + packageInfo.version,
      content: const Text('XIAG AG Internet Solutions\nArchstrasse 7, CH-8400 Winterthur\n+41 (0) 43 255 30 90\napp@xiag.ch'),
      actions: [
        TextButton(
          child: Text(intl().viewLicenses, style: const TextStyle(color: Colors.black)),
          onPressed: () {
            showLicensePage(context: context);
            // Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text(intl().closeButton, style: const TextStyle(color: Colors.blue)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  void _showSubscribeScreen() {
    ScreensManager().showSubscriptionScreen(context);
  }
}
