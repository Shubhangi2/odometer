import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:odometer/core/app_colors.dart';
import 'package:odometer/models/journey_model.dart';
import 'package:odometer/provider/journey_provider.dart';
import 'package:odometer/screens/form_screen.dart';
import 'package:odometer/screens/shared_widgets/custom_button.dart';

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
    if (!mounted) {
      await _waitUntilMounted();
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _waitUntilMounted() async {
    while (!mounted) {
      await Future.delayed(const Duration(milliseconds: 50));
    }
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
              opacity: 0.04,
              // opacity: 0.04,
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
              Row(
                spacing: 16,
                children: [
                  actionCardWidget("assets/disabled_punchin.png", "09:30 AM"),
                  actionCardWidget("assets/punchout.png", "Punch Out"),
                ],
              ),
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

  Widget actionCardWidget(String imagePath, String title) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12),
        // height: 130,
        decoration: BoxDecoration(
          color: const Color(0x1023BBDD),
          borderRadius: BorderRadius.circular(24.0),
          border: Border.all(color: AppColors.borderColor, width: 1.0),
        ),
        child: Column(
          spacing: 12,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, height: 1),
            ),
          ],
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
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0x1023BBDD),
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(color: AppColors.borderColor, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            journey.clientName,
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textGray, fontSize: 15),
          ),
          Text(journey.address, style: TextStyle(fontSize: 12, color: AppColors.textGray)),

          Divider(thickness: 1),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Start time:", style: TextStyle(color: AppColors.hintGray, fontSize: 13)),
                    Text(
                      getFormattedDate(journey.startedAt),
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Start reading:",
                      style: TextStyle(color: AppColors.hintGray, fontSize: 13),
                    ),

                    Text(
                      "${journey.startReading} km",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text(
                    //   "End info:",
                    //   style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                    // ),
                    Text("End time:", style: TextStyle(color: AppColors.hintGray, fontSize: 13)),
                    Text(
                      getFormattedDate(journey.endedAt ?? ''),
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    SizedBox(height: 8),
                    Text("End reading:", style: TextStyle(color: AppColors.hintGray, fontSize: 13)),

                    Text(
                      journey.endReading == null ? "N.A." : "${journey.endReading} km",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          journey.isOngoing
              ? Text(
                  "Ongoing Journey",
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
                )
              : Text(
                  "Distance travelled : ${calculateDistance()}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontSize: 16,
                  ),
                ),
        ],
      ),
    );
  }
}
