import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:odometer/core/failure.dart';
import 'package:odometer/db/dao/journey_dao.dart';
import 'package:odometer/models/end_journey_model.dart';
import 'package:odometer/models/journey_model.dart';
import 'package:odometer/models/start_journey_model.dart';

class JourneyProvider extends ChangeNotifier {
  final JourneyDao dao;

  JourneyProvider({required this.dao});

  Future<Either<Failure, String>> startJourney({
    required StartJourneyModel startJourneyModel,
  }) async {
    return await dao.insertStartJourney(startJourneyModel);
  }

  Future<Either<Failure, String>> endJourney({required EndJourneyModel endJourneyModel}) async {
    return await dao.updateEndJourney(endJourneyModel);
  }

  Future<List<JourneyModel>> getAllJourneys() async {
    return await dao.getAllJourneys();
  }

  Future<List<JourneyModel>> getLastFiveJourneys() async {
    return await dao.getLastFiveJourneys();
  }

  Future<JourneyModel?> getLastJourney() async {
    return await dao.getLastJourney();
  }
}
