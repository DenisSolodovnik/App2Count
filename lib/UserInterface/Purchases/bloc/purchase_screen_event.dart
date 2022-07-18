part of 'purchase_screen_bloc.dart';

abstract class PurchaseScreenEvent extends Equatable {
  const PurchaseScreenEvent();
}

class PurchaseScreenEventLoadProducts extends PurchaseScreenEvent {
  @override
  List<Object> get props => [];
}

class PurchaseScreenEventBuyProduct extends PurchaseScreenEvent {
  final Purchase purchase;

  const PurchaseScreenEventBuyProduct(this.purchase);
  @override
  List<Object> get props => [purchase];
}

class PurchaseScreenEventProductBought extends PurchaseScreenEvent {
  @override
  List<Object> get props => [];
}

class PurchaseScreenEventRestorePurchases extends PurchaseScreenEvent {
  @override
  List<Object> get props => [];
}

class PurchaseScreenEventErrorOccurred extends PurchaseScreenEvent {
  final IAPError? error;

  const PurchaseScreenEventErrorOccurred(this.error);
  @override
  List<Object> get props => [];
}
