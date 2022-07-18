import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class Purchase extends Equatable {
  final String id;
  final String title;
  final String price;
  final ProductDetails details;
  final String purchaseDescription;

  const Purchase(this.id, this.title, this.price, this.details, this.purchaseDescription);

  @override
  List<Object> get props => [title, price, details];
}

enum PurchaseManagerStatus { purchasing, error, purchased, pending, restored }

class PurchaseManager {
  static const String foreverPurchaseID = "ch.xiag.scorekeeper.purchase_forever";
  static const String weekSubscriptionID = "ch.xiag.scorekeeper.subs_weekly";
  static const String yearSubscriptionID = "ch.xaig.scorekeeper.subs_yearly";

  static final PurchaseManager _instance = PurchaseManager._internal();

  static AppLocalizations? intl;
  static String _purchaseDescriptions(String id) {
    switch (id) {
      case yearSubscriptionID:
        return intl?.purchaseYearlyDescription ?? ""; // TODO
      case foreverPurchaseID:
      default:
        return intl?.purchaseForeverDescription ?? ""; // TODO
    }
  }

  static String _purchaseTitle(String id) {
    switch (id) {
      case yearSubscriptionID:
        return intl?.purchaseYearlyTitle ?? ""; // TODO
      case foreverPurchaseID:
      default:
        return intl?.purchaseForeverTitle ?? "";
    }
  }

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;

  factory PurchaseManager() {
    return _instance;
  }

  late StreamSubscription<List<PurchaseDetails>> _subscription;
  final StreamController<PurchaseManagerStatus> _statusStreamController = StreamController<PurchaseManagerStatus>();
  IAPError? error;
  final Map<String, bool> _inappStatus = {
    foreverPurchaseID: false,
    yearSubscriptionID: false,
  };

  PurchaseManager._internal() {
    final Stream<List<PurchaseDetails>> purchaseUpdated = InAppPurchase.instance.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      // handle error here.
    });
  }

  Stream<PurchaseManagerStatus> status() {
    return _statusStreamController.stream;
  }

  Future<List<Purchase>> loadProducts() async {
    final bool _ = await _inAppPurchase.isAvailable();
    const Set<String> _kIds = {foreverPurchaseID, yearSubscriptionID};
    final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(_kIds);
    if (response.notFoundIDs.isNotEmpty) {
      for (var e in response.notFoundIDs) {
        debugPrint(e);
      }
    }
    List<ProductDetails> products = response.productDetails;
    List<Purchase> purchases = [];
    for (var purchase in products) {
      var currencySymbol = purchase.currencySymbol == 'RUB' ? '₽' : purchase.currencySymbol;
      purchases.add(Purchase(
        purchase.id,
        _purchaseTitle(purchase.id),
        purchase.rawPrice.toString() + ' ' + currencySymbol,
        purchase,
        _purchaseDescriptions(purchase.id),
      ));
    }
    return purchases;
  }

  bool isInappPurchased({String inappID = '', bool any = false}) {
    if (any) {
      for (var value in _inappStatus.values) {
        if (value) {
          return true;
        }
      }
    }
    return _inappStatus[inappID] ?? false;
  }

  Future<void> restorePurchases() async {
    final bool _ = await _inAppPurchase.isAvailable();
    await _inAppPurchase.restorePurchases();
    _statusStreamController.add(PurchaseManagerStatus.restored);
  }

  Future<void> buyProduct(Purchase purchaseProduct) async {
    final bool _ = await _inAppPurchase.isAvailable();
    PurchaseParam purchaseParam = PurchaseParam(productDetails: purchaseProduct.details, applicationUserName: null); // sandboxTesting: true
    await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    _statusStreamController.add(PurchaseManagerStatus.purchasing);
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        _statusStreamController.add(PurchaseManagerStatus.pending);
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          _statusStreamController.add(PurchaseManagerStatus.error);
          error = purchaseDetails.error;
        } else if (purchaseDetails.status == PurchaseStatus.purchased || purchaseDetails.status == PurchaseStatus.restored) {
          if (purchaseDetails.productID == foreverPurchaseID) {
            _inappStatus[foreverPurchaseID] = true;
            _statusStreamController.add(PurchaseManagerStatus.purchased);
            return;
          }
          final endDate = purchaseDetails.endDate();
          if (endDate != null && endDate.isAfter(DateTime.now())) {
            _inappStatus[yearSubscriptionID] = true;
            _statusStreamController.add(PurchaseManagerStatus.purchased);
          }
        }
        if (purchaseDetails.pendingCompletePurchase) {
          try {
            await _inAppPurchase.completePurchase(purchaseDetails);
          } catch (e) {
            debugPrint(e.toString());
          }
        }
      }
    });
  }

  void setLocalization(AppLocalizations? localization) {
    intl = localization;
  }
}

extension PurchaseUtils on PurchaseDetails {
  DateTime? endDate() {
    final tdate = transactionDate;
    if (tdate != null) {
      var transactionDate = int.parse(tdate);
      var date = DateTime.fromMillisecondsSinceEpoch(transactionDate);
      var longInDays = productID == "ch.xiag.scorekeeper.subs_weekly" ? 14 : 366;
      return date.add(Duration(days: longInDays));
    } else {
      return null;
    }
  }
}
