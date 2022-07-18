import 'package:flutter_driver/flutter_driver.dart';
import 'package:scorekeeper/UserInterface/widget_keys.dart';
import 'package:test/test.dart';

import 'arguments_helper.dart';

void main() {
  group('Counter App', () {
    late FlutterDriver driver;
    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      await driver.requestData(ArgumentsHelper.toArgs(['--clear']));
      driver.close();
    });
    test('Create players can open', () async {
      await driver.requestData(ArgumentsHelper.toArgs(
          ['--restart', '--database', 'DatabaseWithPlayers']));
      await driver.waitFor(find.byValueKey(ScreenKeys.playersListScreen),
          timeout: const Duration(seconds: 3));
      var addButton = find.byValueKey(ButtonKeys.add);
      await driver.tap(addButton);
      await driver.waitFor(find.byValueKey(ScreenKeys.playerEditScreen),
          timeout: const Duration(seconds: 3));
    });

    test('Settings can open', () async {
      await driver.requestData(ArgumentsHelper.toArgs(['--restart']));
      await driver.waitFor(find.byValueKey(ScreenKeys.playersListScreen),
          timeout: const Duration(seconds: 3));
      var button = find.byValueKey(ButtonKeys.settings);
      await driver.tap(button);
      await driver.waitFor(find.byValueKey(ScreenKeys.settingsScreen),
          timeout: const Duration(seconds: 3));
    });

    test('Can create player', () async {
      await driver.requestData(
          ArgumentsHelper.toArgs(['--restart', '--database', 'EmptyDatabase']));
      await driver.waitFor(find.byValueKey(ScreenKeys.playersListScreen),
          timeout: const Duration(seconds: 3));
      var button = find.byValueKey(ButtonKeys.add);
      await driver.tap(button);
      await driver.waitFor(find.byValueKey(ScreenKeys.playerEditScreen),
          timeout: const Duration(seconds: 3));
      await driver.tap(find.byValueKey(WidgetKeys.playerEditNameTextField));
      await driver.enterText("Player");
      await driver.tap(find.byValueKey(ButtonKeys.createPlayer));
      await driver.waitFor(
          find.byValueKey(WidgetKeys.playerCell + "Player" + "0"),
          timeout: const Duration(seconds: 3));
    });

    test('Resort players on points add', () async {
      await driver.requestData(ArgumentsHelper.toArgs(
          ['--restart', '--database', 'DatabaseWithPlayers']));
      await driver.waitFor(find.byValueKey(ScreenKeys.playersListScreen),
          timeout: const Duration(seconds: 3));
      await driver.tap(find.byValueKey(ButtonKeys.addPoints + 'Masha' + '1'));

      await driver.waitFor(
          find.byValueKey(WidgetKeys.playerCell + "Masha" + "0"),
          timeout: const Duration(seconds: 4));
    });

    test('Resort players on points change in text field', () async {
      await driver.requestData(ArgumentsHelper.toArgs(
          ['--restart', '--database', 'DatabaseWithPlayers']));
      await driver.waitFor(find.byValueKey(ScreenKeys.playersListScreen),
          timeout: const Duration(seconds: 3));
      await driver
          .tap(find.byValueKey(WidgetKeys.playerScoreTextField + "Masha"));
      await driver.enterText("100");
      await driver.scroll(find.byValueKey(ScreenKeys.playersListScreen), 0, 10,
          const Duration(milliseconds: 100));
      await driver.waitFor(
          find.byValueKey(WidgetKeys.playerCell + "Masha" + "0"),
          timeout: const Duration(seconds: 4));
    });

    test('Resort players on add in addition field', () async {
      await driver.requestData(ArgumentsHelper.toArgs(
          ['--restart', '--database', 'DatabaseWithPlayers']));
      await driver.waitFor(find.byValueKey(ScreenKeys.playersListScreen),
          timeout: const Duration(seconds: 3));
      await driver.scroll(find.byValueKey(ButtonKeys.addPoints + 'Masha' + '1'),
          -30, 0, const Duration(milliseconds: 500));

      await driver.tap(find.byValueKey(WidgetKeys.pointsAddTextField));
      await driver.enterText("10");
      await driver.tap(find.byValueKey(ButtonKeys.applyPointsAdd));

      await Future.delayed(const Duration(seconds: 2));
      await driver.waitFor(
          find.byValueKey(WidgetKeys.playerCell + "Masha" + "0"),
          timeout: const Duration(seconds: 4));
    });

    test('Do not resort players on add field open', () async {
      await driver.requestData(ArgumentsHelper.toArgs(
          ['--restart', '--database', 'DatabaseWithPlayers']));
      await driver.waitFor(find.byValueKey(ScreenKeys.playersListScreen),
          timeout: const Duration(seconds: 3));
      await driver.tap(find.byValueKey(ButtonKeys.addPoints + 'Masha' + '1'));
      await driver.scroll(find.byValueKey(ButtonKeys.addPoints + 'Petr' + '0'),
          -25, 0, const Duration(milliseconds: 500));
      await Future.delayed(const Duration(seconds: 2));
      await driver.waitFor(
          find.byValueKey(WidgetKeys.playerCell + "Masha" + "1"),
          timeout: const Duration(seconds: 4));
    });

    test('Do not resort players on points add on field focus', () async {
      await driver.requestData(ArgumentsHelper.toArgs(
          ['--restart', '--database', 'DatabaseWithPlayers']));
      await driver.waitFor(find.byValueKey(ScreenKeys.playersListScreen),
          timeout: const Duration(seconds: 3));
      await driver.tap(find.byValueKey(ButtonKeys.addPoints + 'Masha' + '1'));
      await driver
          .tap(find.byValueKey(WidgetKeys.playerScoreTextField + "Petr"));
      await Future.delayed(const Duration(seconds: 2));
      await driver.waitFor(
          find.byValueKey(WidgetKeys.playerCell + "Masha" + "1"),
          timeout: const Duration(seconds: 4));
    });
  });
}
