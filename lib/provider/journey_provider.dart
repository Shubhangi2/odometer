import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:speedometer/core/failure.dart';
import 'package:speedometer/db/dao/journey_dao.dart';
import 'package:speedometer/models/end_journey_model.dart';
import 'package:speedometer/models/journey_model.dart';
import 'package:speedometer/models/start_journey_model.dart';

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

  Future<JourneyModel?> getLastJourney() async {
    return await dao.getLastJourney();
  }
}
