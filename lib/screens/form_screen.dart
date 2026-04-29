import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:speedometer/core/app_colors.dart';
import 'package:speedometer/core/utility_functions.dart';
import 'package:speedometer/models/end_journey_model.dart';
import 'package:speedometer/models/journey_model.dart';
import 'package:speedometer/models/odometer_model.dart';
import 'package:speedometer/models/start_journey_model.dart';
import 'package:speedometer/provider/journey_provider.dart';
import 'package:speedometer/screens/capture_image_screen.dart';
import 'package:speedometer/screens/shared_widgets/custom_button.dart';
import 'package:speedometer/screens/shared_widgets/custom_dropdown_widget.dart';
import 'package:speedometer/screens/shared_widgets/custom_input_formatter.dart';
import 'package:speedometer/screens/shared_widgets/show_snackbar.dart';

class FormScreen extends StatefulWidget {
  final bool isStartJourney;
  final JourneyModel? startJourneyModel;
  final List<CameraDescription> cameras;

  const FormScreen({
    super.key,
    required this.isStartJourney,
    this.startJourneyModel,
    required this.cameras,
  });
  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  TextEditingController scannedTextController = TextEditingController();

  bool isImageCaptured = false;
  Uint8List? frozenBytes;
  bool isclientSelected = false;
  String selectedClient = "";
  String journeyImage = "";

  List<String> clients = [
    "Shubhangi",
    "Yogita",
    "Renuka",
    "Shrishail",
    "Saurabh",
    "Sandeep",
    "Rushabh",
    "Bhalchandra",
    "Dattatrey",
    "Anirudh",
  ];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    callAsyncTask();

    scannedTextController.addListener(() {
      if (scannedTextController.selection !=
          TextSelection.collapsed(offset: scannedTextController.text.length)) {
        scannedTextController.selection = TextSelection.collapsed(
          offset: scannedTextController.text.length,
        );
      }
    });
  }

  void callAsyncTask() async {
    await UtilityFunctions().getCurrentLocation();
  }

  // Future<void> submitDetails(bool isStartJourney) async {
  //   if (!isclientSelected && isStartJourney) {
  //     showSnackBar(context, "Please select client name", false);
  //     return;
  //   }
  //   if (scannedTextController.text.isEmpty) {
  //     showSnackBar(context, "Speedometer not captured", false);
  //     return;
  //   }
  //   Position? position = await UtilityFunctions().getCurrentLocation();
  //   if (position == null) {
  //     showSnackBar(context, "Location not found", false);
  //     return;
  //   }
  //   if (journeyImage.isEmpty) {
  //     showSnackBar(context, "Image not captured, please try again", false);
  //     return;
  //   }
  //   setState(() {
  //     isLoading = true;
  //   });

  //   final res;
  //   if (!isStartJourney && widget.startJourneyModel != null) {
  //     EndJourneyModel endJourneyModel = EndJourneyModel(
  //       endReading: scannedTextController.text,
  //       endLocation: "${position.latitude},${position.longitude}",
  //       endReadingImage: journeyImage,
  //       endedAt: DateTime.now().toString(),
  //       id: widget.startJourneyModel!.id,
  //       isOngoing: false,
  //     );
  //     res = await context.read<JourneyProvider>().endJourney(endJourneyModel: endJourneyModel);
  //   } else {
  //     StartJourneyModel startJourneyModel = StartJourneyModel(
  //       clientName: selectedClient,
  //       startLocation: "${position.latitude},${position.longitude}",
  //       isOngoing: true,
  //       address: "dummy address",
  //       startReading: scannedTextController.text,
  //       startedAt: DateTime.now().toString(),
  //       startReadingImage: journeyImage,
  //     );
  //     res = await context.read<JourneyProvider>().startJourney(
  //       startJourneyModel: startJourneyModel,
  //     );
  //   }
  //   res.fold((l) => showSnackBar(context, l.message, false), (r) {
  //     showSnackBar(context, r, true);
  //     Navigator.of(context).pop(true);
  //   });
  //   setState(() {
  //     isLoading = false;
  //   });
  // }
  Future<void> submitDetails(bool isStartJourney) async {
    if (!isclientSelected && isStartJourney) {
      showSnackBar(context, "Please select client name", false);
      return;
    }
    if (scannedTextController.text.isEmpty) {
      showSnackBar(context, "Speedometer not captured", false);
      return;
    }

    Position? position = await UtilityFunctions().getCurrentLocation();

    if (!mounted) return; // ✅ guard after await

    if (position == null) {
      showSnackBar(context, "Location not found", false);
      return;
    }
    if (journeyImage.isEmpty) {
      showSnackBar(context, "Image not captured, please try again", false);
      return;
    }

    setState(() => isLoading = true);

    // ✅ capture provider BEFORE awaits
    final provider = context.read<JourneyProvider>();

    final res;
    if (!isStartJourney && widget.startJourneyModel != null) {
      EndJourneyModel endJourneyModel = EndJourneyModel(
        endReading: scannedTextController.text,
        endLocation: "${position.latitude},${position.longitude}",
        endReadingImage: journeyImage,
        endedAt: DateTime.now().toString(),
        id: widget.startJourneyModel!.id,
        isOngoing: false,
      );
      res = await provider.endJourney(endJourneyModel: endJourneyModel);
    } else {
      StartJourneyModel startJourneyModel = StartJourneyModel(
        clientName: selectedClient,
        startLocation: "${position.latitude},${position.longitude}",
        isOngoing: true,
        address: "dummy address",
        startReading: scannedTextController.text,
        startedAt: DateTime.now().toString(),
        startReadingImage: journeyImage,
      );
      res = await provider.startJourney(startJourneyModel: startJourneyModel);
    }

    if (!mounted) return; // ✅ guard before using context again

    res.fold((l) => showSnackBar(context, l.message, false), (r) {
      showSnackBar(context, r, true);
      Navigator.of(context).pop(true); // ✅ now safe
    });

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.bgColor,

        body: Container(
          height: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/bg_image.jpg'),
              fit: BoxFit.cover,
              opacity: 0.1,
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      "${widget.isStartJourney ? "Start" : "End"}-journey Details",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 20),
                  widget.isStartJourney
                      ? CustomDropdownWidget(
                          dropdownList: clients,
                          hintText: "Select Client",

                          icon: Icons.business,
                          onSelected: (value) {
                            setState(() {
                              isclientSelected = true;
                              selectedClient = value;
                            });
                          },
                          itemToString: (item) => item,
                        )
                      : Text(
                          "Selected Client - Client 1",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),

                  const SizedBox(height: 20),
                  Text("Address : ", style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),

                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      border: Border.all(color: AppColors.secondaryBorder, width: 1.5),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    height: MediaQuery.of(context).size.height * 0.40,
                    width: double.infinity,
                    child: isImageCaptured ? _buildFrozenView() : _clickToCaptureView(),
                  ),
                  const SizedBox(height: 12),

                  if (isImageCaptured)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.secondaryBorder, width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 8),
                          const Text(
                            "Odometer Reading",
                            style: TextStyle(color: Colors.white54, fontSize: 12),
                          ),

                          TextFormField(
                            controller: scannedTextController,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(7),
                              CustomInputFormatter(),
                            ],
                            keyboardType: const TextInputType.numberWithOptions(decimal: false),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),

                            decoration: const InputDecoration(border: InputBorder.none),
                          ),
                        ],
                      ),
                    ),

                  SizedBox(height: 24),
                  if (isImageCaptured)
                    CustomButton(
                      text: "Submit",
                      onPressed: () async {
                        await submitDetails(widget.isStartJourney);
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFrozenView() {
    return SizedBox(
      child: frozenBytes != null
          ? Image.memory(frozenBytes!, fit: BoxFit.cover)
          : const Center(child: Text("Image not captured, please try again")),
    );
  }

  Widget _clickToCaptureView() {
    return SizedBox(
      child: InkWell(
        onTap: () async {
          OdometerModel? result = await Navigator.push(
            context,
            MaterialPageRoute<OdometerModel>(
              builder: (context) => CaptureImageScreen(cameras: widget.cameras),
            ),
          );

          if (result != null) {
            setState(() {
              scannedTextController.text = result.odometerValue;
              isImageCaptured = true;
              frozenBytes = result.capturedImage;
              journeyImage = base64Encode(frozenBytes!);
            });
          }
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.secondaryBorder, width: 1.5),
                ),
                child: ClipOval(child: Image.asset('assets/odometer.jpg', fit: BoxFit.cover)),
              ),
              SizedBox(height: 8),
              Text("Click here", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text(
                "To Capture Speedometer Reading",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    scannedTextController.dispose();
    super.dispose();
  }
}
