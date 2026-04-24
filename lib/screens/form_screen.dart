import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:speedometer/core/app_colors.dart';
import 'package:speedometer/screens/shared_widgets/custom_button.dart';
import 'package:speedometer/screens/shared_widgets/custom_dropdown_widget.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:speedometer/screens/shared_widgets/custom_input_formatter.dart';
import 'package:speedometer/screens/shared_widgets/custom_text_form_field.dart';

class FormScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const FormScreen({super.key, required this.cameras});
  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  CameraController? _cameraController;
  final TextRecognizer _textRecognizer = TextRecognizer();
  TextEditingController scannedTextController = TextEditingController();
  TextEditingController addressTextController = TextEditingController();

  bool _isProcessing = false;
  bool _isFrozen = false;

  String _liveReading = "";
  String _frozenReading = "";
  Uint8List? _frozenImageBytes;

  final List<String> _buffer = [];
  String _bestReading = "";
  int _confidence = 0;
  static const int _bufferSize = 15;

  final GlobalKey _previewKey = GlobalKey();

  List<String> clients = ["client 1", "client 2", "client 3"];

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

      if (reading != null) {
        _buffer.add(reading);
        if (_buffer.length > _bufferSize) _buffer.removeAt(0);
        _updateConfidence();
        if (mounted) setState(() => _liveReading = reading);
      }
    } catch (_) {}

    _isProcessing = false;
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

  void _updateConfidence() {
    if (_buffer.isEmpty) return;
    final freq = <String, int>{};
    for (final r in _buffer) {
      freq[r] = (freq[r] ?? 0) + 1;
    }
    final sorted = freq.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.first;
    setState(() {
      _bestReading = top.key;
      _confidence = ((top.value / _buffer.length) * 100).round();
    });
  }

  Future<void> _freezeReading() async {
    await _cameraController?.stopImageStream();

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

  void _scanAgain() {
    _buffer.clear();
    setState(() {
      _liveReading = "";
      _frozenReading = "";
      _bestReading = "";
      _confidence = 0;
      _isFrozen = false;
      _frozenImageBytes = null;
    });
    _cameraController?.startImageStream(_processFrame);
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
                    _liveReading.isNotEmpty ? _liveReading : "Align odometer here",
                    style: TextStyle(
                      color: _confidence >= 80 ? Colors.greenAccent : Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      shadows: const [Shadow(blurRadius: 4, color: Colors.black)],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrozenView() {
    return Stack(
      fit: StackFit.expand,
      children: [
        _frozenImageBytes != null
            ? Image.memory(_frozenImageBytes!, fit: BoxFit.cover)
            : const ColoredBox(color: AppColors.secondary),

        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: AppColors.secondaryBorder, size: 64),
              const SizedBox(height: 12),
              Text(
                "$_frozenReading km",
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
        ),
      ],
    );
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
                  CustomTextFormField(
                    controller: addressTextController,
                    label: "Address",
                    hintText: "Enter address",
                    inputFormatters: [],
                    onValidate: (value) {},
                    textInputType: TextInputType.text,
                  ),
                  SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.secondaryBorder, width: 1.5),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    height: MediaQuery.of(context).size.height * 0.40,
                    width: double.infinity,
                    child: _isFrozen ? _buildFrozenView() : _buildCameraPreview(),
                  ),

                  const SizedBox(height: 12),

                  if (_isFrozen)
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
                  SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isFrozen
                          ? _scanAgain
                          : (_bestReading.isNotEmpty ? _freezeReading : null),
                      icon: Icon(_isFrozen ? Icons.replay : Icons.check),
                      label: Text(
                        _isFrozen ? "Scan Again" : "Confirm Reading",
                        style: const TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isFrozen ? Colors.green : Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        disabledBackgroundColor: Colors.grey.shade800,
                      ),
                    ),
                  ),

                  SizedBox(height: 24),
                  if (_isFrozen) CustomButton(text: "Submit", onPressed: () {}),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
