import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:scorekeeper/UserInterface/Purchases/purchase_cell.dart';
import 'package:scorekeeper/UserInterface/Purchases/bloc/purchase_screen_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:scorekeeper/UserInterface/app_colors.dart';
import 'package:scorekeeper/UserInterface/app_feedback_haptic.dart';
import 'package:scorekeeper/UserInterface/sound_manager.dart';
import 'package:scorekeeper/UserInterface/universal_ui_manager.dart';
import 'package:scorekeeper/UserInterface/widget_keys.dart';
import 'package:url_launcher/url_launcher.dart';

import 'purchase_manager.dart';

class PurchaseScreen extends StatefulWidget {
  const PurchaseScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PurchaseScreenState();
  }
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  PurchaseScreenBloc bloc() {
    return BlocProvider.of<PurchaseScreenBloc>(context);
  }

  @override
  void initState() {
    super.initState();
    bloc().add(PurchaseScreenEventLoadProducts());
  }

  AppLocalizations intl() {
    return AppLocalizations.of(context);
  }

  @override
  Widget build(BuildContext context) {
    PurchaseManager().setLocalization(intl());
    return Scaffold(
      key: const Key(ScreenKeys.subscriptionScreen),
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
          onPressed: () {
            SoundManager().playSound(SoundType.back);
            AppFeedbackHaptic.light();
            Navigator.of(context).pop();
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 81,
                    alignment: Alignment.centerLeft,
                    child: SvgPicture.asset('assets/logo.svg'),
                  ),
                ],
              ),
              Text(
                intl().subscription,
                style: GoogleFonts.oswald(fontSize: 42, fontWeight: FontWeight.w500),
              )
            ],
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(color: AppColors.backgroundColor),
        child: SafeArea(
          child: BlocBuilder<PurchaseScreenBloc, PurchaseScreenState>(
            builder: (context, state) {
              if (state is PurchaseScreenLoaded) {
                return _buildPurchasesArea(_buildLoadedView(state.purchases));
              }
              if (state is PurchaseScreenBuyingProduct) {
                return _buildPurchasesArea(_buildLoadedView(state.purchases));
              }
              if (state is PurchaseScreenError) {
                return _buildPurchasesArea(_buildErrorView(state.error));
              }
              return _buildLoadingView();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return _buildPurchasesArea(
      Container(
        width: 40,
        height: 40,
        child: UniversalUIManager().activityIndicator(),
        alignment: Alignment.center,
      ),
    );
  }

  Widget _buildPurchasesArea(Widget child) {
    List<Widget> cells = [];
    cells.add(_description());

    cells.add(child);

    cells.add(const SizedBox(height: 24));
    if (Platform.isIOS) {
      cells.add(_restorePurchases());
    }
    cells.add(_subscriptionDisclaimer());
    cells.add(_subscriptionCancellationInstruction());
    cells.add(_privacyPolicy());
    cells.add(_termsOfUse());

    return ListView(
      children: cells,
      shrinkWrap: false,
    );
  }

  Widget _buildLoadedView(List<Purchase> purchases) {
    List<Widget> purchaseCells = [];

    for (var purchase in purchases) {
      purchaseCells.add(PurchaseCell(purchase));
    }
    purchaseCells.add(const SizedBox(
      height: 10,
    ));
    return ListView(
      children: purchaseCells,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
    );
  }

  Widget _description() {
    return Column(
      children: [_subscriptionPromo(), _subscriptionProfit_1()],
    );
  }

  Widget _subscriptionPromo() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Text(
        intl().subscriptionTitle,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _subscriptionProfit_1() {
    return Container(padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), child: _profitRow(intl().purchaseProfit_1));
  }

  Widget _profitRow(String title) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.check,
          color: AppColors.orange,
        ),
        const SizedBox(
          width: 10,
        ),
        Flexible(
          child: Text(
            title,
            style: const TextStyle(fontFamily: 'Montserrat', fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.orange),
          ),
        )
      ],
    );
  }

  Widget _restorePurchases() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(intl().alreadyPurchased, style: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.gray80)),
        TextButton(
          child: Text(intl().restorePurchases, style: GoogleFonts.montserrat(fontSize: 17, fontWeight: FontWeight.w400, color: AppColors.linkColor)),
          onPressed: () => bloc().add(PurchaseScreenEventRestorePurchases()),
        )
      ],
    );
  }

  Widget _subscriptionDisclaimer() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Text(
        (Platform.isAndroid ? intl().purchaseStoreDisclaimerAndroid : intl().purchaseStoreDisclaimerIOS),
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey[600]),
      ),
    );
  }

  Widget _subscriptionCancellationInstruction() {
    return _linkContainer(
      intl().purchaseSubscriptionCancellation,
      intl().purchaseSubscriptionCancellationAction,
      (Platform.isAndroid ? intl().purchaseSubscriptionCancellationLinkAndroid : intl().purchaseSubscriptionCancellationLinkIOS),
    );
  }

  Widget _privacyPolicy() {
    return _linkContainer(
      intl().purchasePrivacyPolicyTitle,
      intl().purchasePrivacyPolicyActionTitle,
      intl().purchasePrivacyPolicyLink,
    );
  }

  Widget _termsOfUse() {
    return _linkContainer(
      intl().purchaseTermsOfUseTitle,
      intl().purchaseTermsOfUseActionTitle,
      intl().purchaseTermsOfUseLink,
    );
  }

  Widget _linkContainer(String title, String actionTitle, String linkValue) {
    return Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(title, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
            InkWell(
                child: Text(actionTitle, textAlign: TextAlign.center, style: TextStyle(color: Colors.green[900])), onTap: () => launch(linkValue)),
          ],
        ));
  }

  Widget _buildErrorView(IAPError? error) {
    List<Widget> cells = [];
    cells.add(Text(
      error?.message ?? intl().purchaseError,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
    ));
    cells.add(const SizedBox(
      height: 18,
    ));
    cells.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MaterialButton(
            highlightColor: Colors.transparent,
            splashColor: Colors.green[600],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0), side: const BorderSide(color: Colors.transparent)),
            color: Colors.green[800],
            child: Text(
              intl().purchaseRetryAction,
              style: const TextStyle(color: Colors.white),
            ),
            onPressed: () {
              bloc().add(PurchaseScreenEventLoadProducts());
            },
          )
        ],
      ),
    );
    return ListView(
      children: cells,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
    );
  }
}
