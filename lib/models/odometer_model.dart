import 'dart:typed_data';

class OdometerModel {
  final String odometerValue;
  final Uint8List capturedImage;

  OdometerModel({required this.odometerValue, required this.capturedImage});
}
