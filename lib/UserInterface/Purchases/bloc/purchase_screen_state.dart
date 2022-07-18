part of 'purchase_screen_bloc.dart';

abstract class PurchaseScreenState extends Equatable {
  const PurchaseScreenState();
}

class PurchaseScreenInitial extends PurchaseScreenState {
  @override
  List<Object> get props => [];
}

class PurchaseScreenLoading extends PurchaseScreenState {
  @override
  List<Object> get props => [];
}

class PurchaseScreenLoaded extends PurchaseScreenState {
  final List<Purchase> purchases;

  const PurchaseScreenLoaded(this.purchases);

  @override
  List<Object> get props => [purchases];
}

class PurchaseScreenBuyingProduct extends PurchaseScreenState {
  final Purchase purchase;
  final List<Purchase> purchases;

  const PurchaseScreenBuyingProduct(this.purchase, this.purchases);

  @override
  List<Object> get props => [];
}

class PurchaseScreenError extends PurchaseScreenState {
  final IAPError? error;

  const PurchaseScreenError(this.error);

  @override
  List<Object> get props => [];
}

class PurchaseScreenBought extends PurchaseScreenState {
  const PurchaseScreenBought();

  @override
  List<Object> get props => [];
}
