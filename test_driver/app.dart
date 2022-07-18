import 'package:flutter/cupertino.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:scorekeeper/Storage/data_storage.dart';
import 'package:scorekeeper/main.dart' as app;

import 'arguments_helper.dart';
import 'database_helper.dart';

void main() {
  enableFlutterDriverExtension(handler: (command) async {
    var parser = ArgumentsHelper.parser();
    var argsAsArray = ArgumentsHelper.args(command);
    var args = parser.parse(argsAsArray);

    if (args['restart']) {
      App2scoreDatabase? database;
      if (args['database'] != null) {
        database = await DatabaseHelper.databaseWithIdentifier(args['database']);
      }
      runApp(
        app.MyApp(
          key: UniqueKey(),
          database: database,
        ),
      );
      return 'ok';
    }
    if (args['clear']) {
      await DatabaseHelper.cleanUpAfterTests();
      return 'ok';
    }
    throw Exception('Unknown command');
  });
  app.main();
}
