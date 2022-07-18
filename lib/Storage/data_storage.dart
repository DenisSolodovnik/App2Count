import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:core';
import 'player.dart';

class App2scoreDatabase {
  late Future<void> initFuture;
  late String _path;
  late Database _db;

  static App2scoreDatabase? _instance;

  App2scoreDatabase(String name) {
    initFuture = _init(name);
  }

  Future<void> _init(String name) async {
    _path = await databasePathWithName(name);
    _db = await _openDatabase(_path, name);
  }

  // path

  static Future<String> databaseFolder() async {
    return await getDatabasesPath();
  }

  static Future<String> databasePathWithName(String name) async {
    var databasePath = await databaseFolder();
    return join(databasePath, name);
  }

  // shared

  static Future<App2scoreDatabase> shared() async {
    if (_instance == null) {
      _instance = App2scoreDatabase("DatabaseWithPlayers.db"); // "data.db"
      await _instance!.initFuture;
    }
    return _instance!;
  }

  // test db forwarding

  static void setInstance(App2scoreDatabase newDatabaseInstance) {
    _instance = newDatabaseInstance;
  }

  // open/create db

  static Future<Database> _openDatabase(String path, name) async {
    return await openDatabase(join(path, name), onCreate: (db, version) {
      _createPlayersTable(db);
    }, onUpgrade: (db, oldVersion, newVersion) {}, version: 1);
  }

  static Future<void> _createPlayersTable(Database db) {
    return db.execute(
      "CREATE TABLE player("
      "identifier TEXT PRIMARY KEY,"
      "name TEXT,"
      "points INTEGER,"
      "pointsDelta INTEGER,"
      "colorValue INTEGER)",
    );
  }

  // insert players

  Future<int> insertPlayer(Player player) async {
    return _db.insert(
      'player',
      player.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Object?>> insertPlayers(List<Player> players) async {
    var batch = _db.batch();
    for (var player in players) {
      batch.insert(
        'player',
        player.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    return batch.commit();
  }

  // get players

  Future<List<Player>> getPlayers() async {
    final players = await _db.query("player");
    return players.map((e) {
      return Player.fromJson(e);
    }).toList();
  }

  // remove players

  Future<int> removePlayer(Player player) async {
    return _db.rawDelete("Delete from player where identifier = '${player.identifier}'");
  }

  Future<int> removeAllPlayers() async {
    return _db.rawDelete("Delete from player");
  }
}
