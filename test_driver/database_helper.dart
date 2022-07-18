import 'dart:io';
import 'package:flutter/material.dart';
import 'package:scorekeeper/Storage/data_storage.dart';
import 'package:scorekeeper/Storage/player.dart';
import 'package:uuid/uuid.dart';

class DatabaseHelper {
  static final _databaseNamesToCleanUp = ["DatabaseWithPlayers.db", "EmptyDatabase.db"];

  static Future<App2scoreDatabase> databaseWithPlayers() async {
    var database = await App2scoreDatabase.shared();
    await database.removeAllPlayers();
    await database.insertPlayer(Player(identifier: const Uuid().v4(), name: "Petr", colorValue: Colors.blue.value));
    await database.insertPlayer(Player(identifier: const Uuid().v4(), name: "Masha", colorValue: Colors.purple.value));
    return database;
  }

  static Future<App2scoreDatabase> emptyDatabase() async {
    var database = await App2scoreDatabase.shared();
    await database.removeAllPlayers();
    return database;
  }

  static Future<void> cleanUpAfterTests() async {
    for (int i = 0; i < _databaseNamesToCleanUp.length; i++) {
      var path = await App2scoreDatabase.databasePathWithName(_databaseNamesToCleanUp[i]);
      var file = File(path);
      if (await file.exists()) {
        try {
          await file.delete();
        } catch (e) {
          debugPrint(e.toString());
        }
      }
    }
  }

  static Future<App2scoreDatabase> databaseWithIdentifier(String identifier) {
    switch (identifier) {
      case 'DatabaseWithPlayers':
        {
          return DatabaseHelper.databaseWithPlayers();
        }
      case 'EmptyDatabase':
        {
          return DatabaseHelper.emptyDatabase();
        }
    }
    throw Exception('Unknown database $identifier');
  }
}
