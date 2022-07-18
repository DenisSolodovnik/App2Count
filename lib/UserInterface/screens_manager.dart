import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scorekeeper/Storage/player.dart';
import 'package:scorekeeper/UserInterface/Purchases/purchase_screen.dart';
import 'package:scorekeeper/UserInterface/Purchases/bloc/purchase_screen_bloc.dart';

import 'package:scorekeeper/UserInterface/PlayersScreen/player_edit_dialog.dart';

class ScreensManager {
  void showSubscriptionScreen(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (BuildContext context) {
        return BlocProvider(create: (context) => PurchaseScreenBloc(), child: const PurchaseScreen());
      },
    ));
  }

  void showPlayerEditDialog({
    required BuildContext context,
    required Player player,
    required PlayerEditDialogDelegate delegate,
  }) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (BuildContext context) {
        return PlayerEditDialog(delegate, player: player);
      },
    ));
  }
}

class FadeRoute extends PageRouteBuilder {
  final Widget page;

  FadeRoute({required this.page})
      : super(
            pageBuilder: (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
            ) =>
                page,
            transitionsBuilder: (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child,
            ) =>
                FadeTransition(opacity: animation, child: child));
}
