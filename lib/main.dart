import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:scorekeeper/Storage/data_storage.dart';
import 'package:scorekeeper/Storage/user_settings.dart';
import 'package:scorekeeper/UserInterface/PlayersScreen/bloc/bloc.dart';

import 'UserInterface/PlayersScreen/players_screen.dart';
import 'UserInterface/Purchases/purchase_manager.dart';

// Import `in_app_purchase_android.dart` to be able to access the
// `InAppPurchaseAndroidPlatformAddition` class.
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:flutter/foundation.dart';

void main() {
  // WidgetsFlutterBinding.ensureInitialized();
  if (defaultTargetPlatform == TargetPlatform.android) {
    // For play billing library 2.0 on Android, it is mandatory to call
    // [enablePendingPurchases](https://developer.android.com/reference/com/android/billingclient/api/BillingClient.Builder.html#enablependingpurchases)
    // as part of initializing the app.
    InAppPurchaseAndroidPlatformAddition.enablePendingPurchases();
  }

  runApp(MyApp());
  PurchaseManager().loadProducts();
}

class MyApp extends StatelessWidget {
  final App2scoreDatabase? database;
  final ThemeData theme = ThemeData();
  @override
  Widget build(BuildContext context) {
    UserSettings().init();
    return MaterialApp(
      themeMode: ThemeMode.light,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('de', ''),
        Locale('ru', ''),
      ],
      title: 'app2count',
      theme: ThemeData(
        colorScheme: theme.colorScheme.copyWith(primary: Colors.black),
        buttonTheme: const ButtonThemeData(
          textTheme: ButtonTextTheme.primary, //  <-- this auto selects the right color
        ),
      ),
      home: BlocProvider(
        create: (c) => PlayersListBloc(),
        child: const PlayersScreen(),
      ),
    );
  }

  MyApp({
    this.database,
    Key? key,
  }) : super(key: key) {
    if (database != null) {
      App2scoreDatabase.setInstance(database!);
    }
  }
}
