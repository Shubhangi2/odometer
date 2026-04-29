import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:speedometer/core/app_colors.dart';
import 'package:speedometer/models/journey_model.dart';
import 'package:speedometer/provider/journey_provider.dart';
import 'package:speedometer/screens/form_screen.dart';
import 'package:speedometer/screens/shared_widgets/custom_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late JourneyModel? currentJourneyModel;
  List<JourneyModel> journeys = [];
  bool isOngoingJourney = false;
  late List<CameraDescription> cameras;

  @override
  void initState() {
    super.initState();
    callAsyncTask();
  }

  Future<void> callAsyncTask() async {
    currentJourneyModel = await context.read<JourneyProvider>().getLastJourney();
    journeys = await context.read<JourneyProvider>().getLastFiveJourneys();
    if (currentJourneyModel != null && currentJourneyModel!.isOngoing == true) {
      isOngoingJourney = true;
    } else {
      isOngoingJourney = false;
    }
    cameras = await availableCameras();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.bgColor,
        body: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/bg_image.jpg'),
              fit: BoxFit.cover,
              opacity: 0.1,
            ),
          ),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 28),
              Text('Hello', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, height: 1)),
              SizedBox(height: 12),
              Text(
                'Shubhangi Jadhav',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, height: 1),
              ),
              SizedBox(height: 16),
              Row(spacing: 16, children: [actionCardWidget(), actionCardWidget()]),
              SizedBox(height: 16),
              !isOngoingJourney
                  ? CustomButton(
                      text: "Start Journey",
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                FormScreen(isStartJourney: true, cameras: cameras),
                          ),
                        );
                        await callAsyncTask();
                      },
                    )
                  : SizedBox(),
              SizedBox(height: isOngoingJourney ? 0 : 16),
              isOngoingJourney
                  ? Column(
                      children: [
                        Text("Journey in progress - Tap to end", style: TextStyle(fontSize: 14)),
                        SizedBox(height: 12),
                        CustomButton(
                          text: "End Journey",
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute<bool>(
                                builder: (context) => FormScreen(
                                  isStartJourney: false,
                                  cameras: cameras,
                                  startJourneyModel: currentJourneyModel,
                                ),
                              ),
                            );

                            await callAsyncTask();
                          },
                          color: Colors.red,
                          borderColor: const Color.fromARGB(255, 241, 95, 85),
                        ),
                        SizedBox(height: 24),
                      ],
                    )
                  : SizedBox(),

              Text("Recent Journeys", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  itemBuilder: (context, index) => historyWidget(journeys[index]),
                  itemCount: journeys.length,
                  separatorBuilder: (BuildContext context, int index) {
                    return const SizedBox(height: 16);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget actionCardWidget() {
    return Expanded(
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          color: const Color(0x1023BBDD),
          borderRadius: BorderRadius.circular(24.0),
          border: Border.all(color: const Color(0xFF23BCDD), width: 1.0),
        ),
      ),
    );
  }

  Widget historyWidget(JourneyModel journey) {
    String getFormattedDate(String date) {
      print(date);
      if (date.isEmpty) return "N.A.";
      DateTime dateTime = DateTime.parse(date);
      String formattedDate = DateFormat("dd MMM hh:mm a").format(dateTime);
      return formattedDate;
    }

    String calculateDistance() {
      if (journey.endReading == null) return "N.A.";
      int startReading = int.parse(journey.startReading) % 1000;
      int endReading = int.parse(journey.endReading!) % 1000;

      int distance = endReading - startReading;

      if (distance < 0) distance += 1000;

      return "${distance.toString()} Km";
    }

    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0x1023BBDD),
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(color: const Color(0xFF23BCDD), width: 1.0),
      ),
      child: Column(
        children: [
          Text(
            journey.clientName,
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textGray),
          ),
          SizedBox(
            // width: double.infinity,
            child: journey.isOngoing
                ? Text(
                    "Ongoing Journey",
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  )
                : Text(
                    "Distance travelled : ${calculateDistance()}",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Column(
                  spacing: 4,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Start info:",
                      style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                    Row(
                      spacing: 4,
                      children: [
                        Icon(Icons.access_time, color: Colors.white, size: 18),
                        Text(getFormattedDate(journey.startedAt)),
                      ],
                    ),

                    Row(
                      spacing: 4,
                      children: [
                        Icon(Icons.speed, color: Colors.white, size: 18),
                        Text("${journey.startReading} km"),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  spacing: 4,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "End info:",
                      style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                    Row(
                      spacing: 4,
                      children: [
                        Icon(Icons.access_time, color: Colors.white, size: 18),
                        Text(getFormattedDate(journey.endedAt ?? '')),
                      ],
                    ),
                    Row(
                      spacing: 4,
                      children: [
                        Icon(Icons.speed, color: Colors.white, size: 18),
                        Text(journey.endReading == null ? "N.A." : "${journey.endReading} km"),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }
}
