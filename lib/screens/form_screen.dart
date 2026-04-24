import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speedometer/core/app_colors.dart';
import 'package:speedometer/models/odometer_model.dart';
import 'package:speedometer/screens/capture_image_screen.dart';
import 'package:speedometer/screens/shared_widgets/custom_button.dart';
import 'package:speedometer/screens/shared_widgets/custom_dropdown_widget.dart';
import 'package:speedometer/screens/shared_widgets/custom_input_formatter.dart';

class FormScreen extends StatefulWidget {
  const FormScreen({super.key});
  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  TextEditingController scannedTextController = TextEditingController();
  TextEditingController addressTextController = TextEditingController();

  late List<CameraDescription> cameras;

  bool isImageCaptured = false;
  Uint8List? frozenBytes;

  List<String> clients = ["client 1", "client 2", "client 3"];

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
    cameras = await availableCameras();
  }

  @override
  void dispose() {
    scannedTextController.dispose();
    super.dispose();
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
                      "Start-journey Details",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 20),
                  CustomDropdownWidget(
                    dropdownList: clients,
                    hintText: "Select Client",
                    icon: Icons.business,
                    onSelected: (value) {},
                    itemToString: (item) => item,
                  ),

                  const SizedBox(height: 20),
                  Text("Address : "),
                  SizedBox(height: 12),

                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      border: Border.all(color: AppColors.secondaryBorder, width: 1.5),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    height: MediaQuery.of(context).size.height * 0.40,
                    width: double.infinity,
                    child: isImageCaptured ? _buildFrozenView() : _captureImageScreen(),
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
                              LengthLimitingTextInputFormatter(20),
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
                  if (isImageCaptured) CustomButton(text: "Submit", onPressed: () {}),
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

  Widget _captureImageScreen() {
    return SizedBox(
      child: InkWell(
        onTap: () async {
          OdometerModel? result = await Navigator.push(
            context,
            MaterialPageRoute<OdometerModel>(
              builder: (context) => CaptureImageScreen(cameras: cameras),
            ),
          );

          if (result != null) {
            setState(() {
              scannedTextController.text = result.odometerValue;
              isImageCaptured = true;
              frozenBytes = result.capturedImage;
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
}
