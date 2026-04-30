import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:speedometer/core/app_colors.dart';
import 'package:speedometer/models/odometer_model.dart';
import 'package:speedometer/screens/shared_widgets/show_snackbar.dart';

class CaptureImageScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const CaptureImageScreen({super.key, required this.cameras});

  @override
  State<CaptureImageScreen> createState() => _CaptureImageScreenState();
}

class _CaptureImageScreenState extends State<CaptureImageScreen> {
  CameraController? _cameraController;
  TextEditingController scannedTextController = TextEditingController();

  final TextRecognizer _textRecognizer = TextRecognizer();
  String _liveReading = "";
  String _frozenReading = "";
  Uint8List? _frozenImageBytes;

  final GlobalKey _previewKey = GlobalKey();

  final List<String> _buffer = [];
  String _bestReading = "";

  bool _isProcessing = false;
  bool _isFrozen = false;
  static const int _bufferSize = 15;

  @override
  void initState() {
    super.initState();
    _initCamera();
    scannedTextController.addListener(() {
      if (scannedTextController.selection !=
          TextSelection.collapsed(offset: scannedTextController.text.length)) {
        scannedTextController.selection = TextSelection.collapsed(
          offset: scannedTextController.text.length,
        );
      }
    });
  }

  @override
  void dispose() {
    scannedTextController.dispose();
    super.dispose();
  }

  Future<void> _initCamera() async {
    _cameraController = CameraController(
      widget.cameras[0],
      ResolutionPreset.veryHigh,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.nv21,
    );
    await _cameraController!.initialize();
    if (!mounted) return;
    setState(() {});
    _cameraController!.startImageStream(_processFrame);
  }

  InputImage? _convertToInputImage(CameraImage image) {
    final camera = widget.cameras[0];
    final rotation = InputImageRotationValue.fromRawValue(camera.sensorOrientation);
    if (rotation == null) return null;
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) return null;
    final plane = image.planes[0];
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  String? _extractOdometer(String rawText) {
    final tokens = rawText
        .replaceAll(RegExp(r'[^0-9\n ]'), ' ')
        .split(RegExp(r'[\s\n]+'))
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final candidates = tokens.where((t) {
      if (t.length < 4 || t.length > 7) return false;
      final v = int.tryParse(t);
      return v != null && v >= 0 && v <= 9999999;
    }).toList();

    if (candidates.isEmpty) return null;

    candidates.sort((a, b) {
      if (b.length != a.length) return b.length.compareTo(a.length);
      return a.compareTo(b);
    });

    return candidates.first;
  }

  Future<void> _processFrame(CameraImage cameraImage) async {
    if (_isProcessing || _isFrozen) return;
    _isProcessing = true;

    try {
      final inputImage = _convertToInputImage(cameraImage);
      if (inputImage == null) {
        _isProcessing = false;
        return;
      }

      final recognized = await _textRecognizer.processImage(inputImage);
      final reading = _extractOdometer(recognized.text);

      _buffer.add(reading ?? '');
      if (_buffer.length > _bufferSize) _buffer.removeAt(0);
      if (mounted) setState(() => _liveReading = reading ?? '');
    } catch (_) {}

    _isProcessing = false;
  }

  void _scanAgain() {
    _buffer.clear();
    setState(() {
      _liveReading = "";
      _frozenReading = "";
      _isFrozen = false;
      _bestReading = "";
      _frozenImageBytes = null;
    });
    _cameraController?.startImageStream(_processFrame);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text("Scan Odometer"), centerTitle: true),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/bg_image.jpg'),
              fit: BoxFit.cover,
              opacity: 0.04,
            ),
          ),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.secondaryBorder, width: 1.5),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    height: MediaQuery.of(context).size.height * 0.40,
                    width: double.infinity,
                    child: _isFrozen ? _buildFrozenView() : _buildCameraPreview(),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _liveReading.isEmpty ? "-" : "$_liveReading km",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          shadows: [Shadow(blurRadius: 6, color: Colors.black)],
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Odometer captured",
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),

              Container(
                padding: EdgeInsets.only(top: 30, bottom: 80),

                decoration: BoxDecoration(color: AppColors.secondary),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _isFrozen
                        ? InkWell(
                            onTap: _scanAgain,
                            child: Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const ui.Color(0xFF4D4D4D),
                              ),
                              child: Center(
                                child: Icon(Icons.close, color: Colors.white, size: 34),
                              ),
                            ),
                          )
                        : SizedBox(),
                    InkWell(
                      onTap: _freezeReading,
                      child: Container(
                        height: 90,
                        width: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const ui.Color(0xFF4D4D4D), width: 10),
                          color: AppColors.textGray,
                        ),
                        child: Center(
                          child: Text(
                            "capture",
                            style: TextStyle(
                              fontSize: 16,
                              color: const ui.Color.fromARGB(255, 57, 60, 65),
                            ),
                          ),
                        ),
                      ),
                    ),
                    _isFrozen
                        ? InkWell(
                            onTap: () {
                              if (_frozenImageBytes == null || _frozenImageBytes!.isEmpty) {
                                showSnackBar(
                                  context,
                                  "Image not captured, Please try again",
                                  false,
                                );
                                _scanAgain();
                                return;
                              }

                              if (_liveReading.isEmpty) {
                                showSnackBar(
                                  context,
                                  "Reading not captured, Please try again",
                                  false,
                                );
                                _scanAgain();
                                return;
                              }
                              Navigator.pop(
                                context,
                                OdometerModel(
                                  odometerValue: _liveReading,
                                  capturedImage: _frozenImageBytes!,
                                ),
                              );
                            },
                            child: Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const ui.Color(0xFF4D4D4D),
                              ),
                              child: Center(
                                child: Icon(Icons.check, color: Colors.white, size: 34),
                              ),
                            ),
                          )
                        : SizedBox(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _freezeReading() async {
    if (_cameraController != null &&
        _cameraController!.value.isInitialized &&
        _cameraController!.value.isStreamingImages) {
      await _cameraController!.stopImageStream();
    }
    try {
      final boundary = _previewKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary != null) {
        final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
        final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        final Uint8List? pngBytes = byteData?.buffer.asUint8List();

        setState(() {
          _frozenImageBytes = pngBytes;
          print(_frozenImageBytes);
          _frozenReading = _bestReading.isNotEmpty ? _bestReading : _liveReading;
          scannedTextController.text = _frozenReading;
          _isFrozen = true;
        });
        return;
      }
    } catch (e) {
      debugPrint("Snapshot error: $e");
    }

    setState(() {
      _frozenReading = _bestReading.isNotEmpty ? _bestReading : _liveReading;
      scannedTextController.text = _frozenReading;
      _isFrozen = true;
    });
  }

  Widget _buildCameraPreview() {
    return RepaintBoundary(
      key: _previewKey,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _cameraController?.value.isInitialized == true
                ? CameraPreview(_cameraController!)
                : const ColoredBox(
                    color: Colors.black,
                    child: Center(child: CircularProgressIndicator()),
                  ),

            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.95,
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary, width: 2),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Text(
                    _liveReading.isNotEmpty ? "" : "Align odometer here",
                    style: TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      shadows: const [Shadow(blurRadius: 4, color: Colors.black)],
                    ),
                  ),
                ),
              ),
            ),

            // SizedBox(
            //   width: double.infinity,
            //   child: ElevatedButton.icon(
            //     onPressed: _isFrozen
            //         ? _scanAgain
            //         : (_bestReading.isNotEmpty ? _freezeReading : null),
            //     icon: Icon(_isFrozen ? Icons.replay : Icons.check),
            //     label: Text(
            //       _isFrozen ? "Scan Again" : "Confirm Reading",
            //       style: const TextStyle(fontSize: 16),
            //     ),
            //     style: ElevatedButton.styleFrom(
            //       backgroundColor: _isFrozen ? Colors.green : Colors.blue,
            //       foregroundColor: Colors.white,
            //       padding: const EdgeInsets.symmetric(vertical: 14),
            //       disabledBackgroundColor: Colors.grey.shade800,
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrozenView() {
    return SizedBox(
      child: _frozenImageBytes != null
          ? Image.memory(_frozenImageBytes!, fit: BoxFit.cover)
          : const ColoredBox(color: AppColors.secondary),
    );
  }
}
