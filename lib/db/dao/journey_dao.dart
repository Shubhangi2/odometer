import 'package:fpdart/fpdart.dart';
import 'package:odometer/core/failure.dart';
import 'package:odometer/db/sql_helper.dart';
import 'package:odometer/db/tables/journey_table.dart';
import 'package:odometer/models/journey_model.dart';
import 'package:odometer/models/start_journey_model.dart';
import 'package:odometer/models/end_journey_model.dart';
import 'package:sqflite/sqflite.dart';

class JourneyDao {
  final SqlHelper sqlHelper;

  JourneyDao([SqlHelper? dbProvider]) : sqlHelper = dbProvider ?? SqlHelper.dbProvider;

  Future<Either<Failure, String>> insertStartJourney(StartJourneyModel startJourneyModel) async {
    final db = await sqlHelper.database;
    try {
      Map<String, dynamic> journeyMap = startJourneyModel.toJson();
      print(journeyMap);
      var res = await db.insert(JourneyTable.tableName, journeyMap);
      print(res);
      return right("journey started successfully");
    } catch (e) {
      print(e);
      return left(Failure("Failed to start journey"));
    }
  }

  Future<Either<Failure, String>> updateEndJourney(EndJourneyModel endJourneyModel) async {
    final db = await sqlHelper.database;
    try {
      Map<String, dynamic> endJourneyMap = endJourneyModel.toJson();
      endJourneyMap.remove('id');
      print(endJourneyMap);
      var res = await db.update(
        JourneyTable.tableName,
        endJourneyMap,
        where: "id = ?",
        whereArgs: [endJourneyModel.id],
      );
      print(res);
      return right("journey ended successfully");
    } catch (e) {
      print(e);
      return left(Failure("Failed to end journey"));
    }
  }

  Future<List<JourneyModel>> getAllJourneys() async {
    final db = await sqlHelper.database;
    try {
      var res = await db.query(JourneyTable.tableName, orderBy: '${JourneyTable.columnId} DESC');

      List<JourneyModel> journeys = [];
      for (var journey in res) {
        print(journey);
        journeys.add(JourneyModel.fromJson(journey));
      }
      return journeys;
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<List<JourneyModel>> getLastFiveJourneys() async {
    final db = await sqlHelper.database;
    try {
      var res = await db.query(
        JourneyTable.tableName,
        orderBy: '${JourneyTable.columnId} DESC',
        limit: 5,
      );

      List<JourneyModel> journeys = [];
      for (var journey in res) {
        print(journey);
        journeys.add(JourneyModel.fromJson(journey));
      }
      return journeys;
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<JourneyModel?> getLastJourney() async {
    final db = await sqlHelper.database;
    try {
      var res = await db.query(
        JourneyTable.tableName,
        orderBy: '${JourneyTable.columnId} DESC',
        limit: 1,
      );
      print(res);
      if (res.isEmpty) return null;
      return JourneyModel.fromJson(res.first);
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<bool> deleteJourneyById(int id) async {
    final db = await sqlHelper.database;
    try {
      var res = await db.delete(JourneyTable.tableName, where: "id = ?", whereArgs: [id]);
      print(res);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
