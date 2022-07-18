import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scorekeeper/UserInterface/Purchases/bloc/purchase_screen_bloc.dart';
import 'package:scorekeeper/UserInterface/app_colors.dart';
import 'package:scorekeeper/UserInterface/universal_ui_manager.dart';

import 'purchase_manager.dart';

class PurchaseCell extends StatefulWidget {
  final Purchase purchase;

  const PurchaseCell(this.purchase, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PurchaseCellState();
  }
}

class _PurchaseCellState extends State<PurchaseCell> {
  PurchaseScreenBloc bloc() {
    return BlocProvider.of<PurchaseScreenBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PurchaseScreenBloc, PurchaseScreenState>(
      builder: (context, state) {
        var isLoading = false;
        if (state is PurchaseScreenBuyingProduct) {
          isLoading = state.purchase == widget.purchase;
        }
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
          child: TextButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(_isPurchased() ? AppColors.inappDisabledButtonColor : Colors.white),
              elevation: MaterialStateProperty.all(1),
              shadowColor: MaterialStateProperty.all(AppColors.gray80),
              shape: MaterialStateProperty.all(const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(13)))),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              title: Text(
                widget.purchase.purchaseDescription,
                textAlign: TextAlign.left,
                style: const TextStyle(fontFamily: 'Montserrat', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.gray80),
              ),
              trailing: _buyButton(isLoading),
            ),
            onPressed: _isPurchased() ? null : () => bloc().add(PurchaseScreenEventBuyProduct(widget.purchase)),
          ),
        );
      },
    );
  }

  Widget _buttonChild(bool isLoading) {
    if (isLoading) {
      return SizedBox(height: 20, width: 20, child: UniversalUIManager().activityIndicator());
    }
    if (_isPurchased()) {
      return const Icon(Icons.check, color: AppColors.gray80);
    }
    return Text(
      widget.purchase.price,
      style: const TextStyle(fontFamily: 'Montserrat', fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.gray80),
    );
  }

  Widget _buyButton(bool isLoading) {
    return Container(
      alignment: Alignment.center,
      width: _isPurchased() ? 42 : 120,
      height: _isPurchased() ? 42 : 52,
      decoration: const BoxDecoration(color: AppColors.inappButtonColor, borderRadius: BorderRadius.all(Radius.circular(50))),
      child: _buttonChild(isLoading),
    );
  }

  bool _isPurchased() {
    return PurchaseManager().isInappPurchased(inappID: widget.purchase.id);
  }
}
