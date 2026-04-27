import 'package:sqflite/sqflite.dart';

class JourneyTable {
  static const String tableName = 'journey';
  static const String columnId = 'id';
  static const String columnIsOngoing = 'isOngoing';
  static const String columnClientName = 'clientName';
  static const String columnAddress = 'address';
  static const String columnStartReading = 'startReading';
  static const String columnStartReadingImage = 'startReadingImage';
  static const String columnStartLocation = 'startLocation';
  static const String columnStartedAt = 'startedAt';
  static const String columnEndedAt = 'endedAt';
  static const String columnEndReading = 'endReading';
  static const String columnEndLocation = 'endLocation';
  static const String columnEndReadingImage = 'endReadingImage';
  static const String columnIsSyncedOnline = 'isSyncedOnline';

  static void createTable(Database database) async {
    try {
      await database.execute('''
        CREATE TABLE $tableName(
          $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
          $columnIsOngoing TEXT,
          $columnClientName TEXT,
          $columnAddress TEXT,
          $columnStartReading TEXT,
          $columnStartReadingImage TEXT,
          $columnStartLocation TEXT,
          $columnStartedAt TEXT,
          $columnEndReading TEXT,
          $columnEndReadingImage TEXT,
          $columnEndLocation TEXT,
          $columnEndedAt TEXT,
          $columnIsSyncedOnline TEXT
        )''');
    } catch (e) {
      print(e);
    }
  }
}
