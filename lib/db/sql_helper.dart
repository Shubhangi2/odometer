import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:speedometer/db/tables/journey_table.dart';
import 'package:sqflite/sqflite.dart';

class SqlHelper {
  static final SqlHelper dbProvider = SqlHelper();

  static const DATABASE_NAME = "speedometer.flutter.db";
  static const DATABASE_VERSION = 1;

  Database? _database;

  Future<Database> get database async {
    _database ??= await createDatabase();
    return _database!;
  }

  Future<Database> createDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, DATABASE_NAME);
    print(path);
    try {
      Database database = await openDatabase(path, version: DATABASE_VERSION, onCreate: initDB);
      return database;
    } catch (e) {
      print(e.toString());
      rethrow;
    }
  }

  void initDB(Database database, int version) async {
    JourneyTable.createTable(database);
  }

  Future<void> clearAllTables() async {
    final db = await database;
    await db.execute("DELETE FROM ${JourneyTable.tableName}");
  }
}
