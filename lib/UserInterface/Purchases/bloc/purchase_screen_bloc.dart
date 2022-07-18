import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:scorekeeper/UserInterface/Purchases/purchase_manager.dart';

part 'purchase_screen_event.dart';

part 'purchase_screen_state.dart';

class PurchaseScreenBloc extends Bloc<PurchaseScreenEvent, PurchaseScreenState> {
  PurchaseScreenBloc() : super(PurchaseScreenInitial());

  List<Purchase> purchases = [];
  StreamSubscription<PurchaseManagerStatus>? _subscription;

  @override
  Stream<PurchaseScreenState> mapEventToState(PurchaseScreenEvent event) async* {
    if (event is PurchaseScreenEventLoadProducts) {
      yield PurchaseScreenLoading();
      purchases = await PurchaseManager().loadProducts();
      yield PurchaseScreenLoaded(purchases);
    }
    if (event is PurchaseScreenEventBuyProduct) {
      yield PurchaseScreenBuyingProduct(event.purchase, purchases);
      try {
        await PurchaseManager().buyProduct(event.purchase);
        _subscription = PurchaseManager().status().listen((status) {
          switch (status) {
            case PurchaseManagerStatus.purchased:
              {
                add(PurchaseScreenEventProductBought());
                return;
              }
            case PurchaseManagerStatus.error:
              {
                add(PurchaseScreenEventErrorOccurred(PurchaseManager().error));
                return;
              }
            default:
              {
                return;
              }
          }
        }, onDone: () {
          _subscription?.cancel();
        }, onError: (error) {
          _subscription?.cancel();
        });
      } catch (e) {
        yield PurchaseScreenError(e is IAPError? ? e as IAPError? : IAPError(source: "", code: "1", message: 'Purchase error!'));
      }
    }
    if (event is PurchaseScreenEventRestorePurchases) {
      yield PurchaseScreenLoading();
      await PurchaseManager().restorePurchases();
      purchases = await PurchaseManager().loadProducts();
      yield PurchaseScreenLoaded(purchases);
    }
    if (event is PurchaseScreenEventProductBought) {
      yield const PurchaseScreenBought();
    }

    if (event is PurchaseScreenEventErrorOccurred) {
      yield PurchaseScreenError(event.error);
    }
  }
}
