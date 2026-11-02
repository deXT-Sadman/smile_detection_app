import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';

import '../model/face_analysis_result.dart';

class FaceAnalysisController extends ChangeNotifier {
  FaceAnalysisController({ImagePicker? imagePicker})
    : _imagePicker = imagePicker ?? ImagePicker();

  final ImagePicker _imagePicker;
  bool _isDisposed = false;

  FaceAnalysisResult? result;
  String? selectedImagePath;
  String? errorMessage;
  bool isAnalyzing = false;

  Future<void> selectImage() async {
    if (isAnalyzing || _isDisposed) return;

    try {
      final image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image == null || _isDisposed) return;

      selectedImagePath = image.path;
      result = null;
      errorMessage = null;
      isAnalyzing = true;
      _notifyListeners();

      final imageSize = await _readImageSize(image.path);
      final detector = FaceDetector(
        options: FaceDetectorOptions(
          enableClassification: true,
          performanceMode: FaceDetectorMode.accurate,
        ),
      );

      late final List<Face> faces;
      try {
        faces = await detector.processImage(
          InputImage.fromFilePath(image.path),
        );
      } finally {
        await detector.close();
      }

      if (_isDisposed) return;
      result = FaceAnalysisResult(
        imagePath: image.path,
        imageSize: imageSize,
        faces: faces,
      );
      isAnalyzing = false;
      _notifyListeners();
    } catch (error, stackTrace) {
      debugPrint('Face image analysis failed: $error\n$stackTrace');
      if (_isDisposed) return;
      isAnalyzing = false;
      errorMessage = 'We couldn’t analyze this image. Please try another.';
      _notifyListeners();
    }
  }

  Future<ui.Size> _readImageSize(String path) async {
    final codec = await ui.instantiateImageCodec(
      await File(path).readAsBytes(),
    );
    try {
      final frame = await codec.getNextFrame();
      try {
        return ui.Size(
          frame.image.width.toDouble(),
          frame.image.height.toDouble(),
        );
      } finally {
        frame.image.dispose();
      }
    } finally {
      codec.dispose();
    }
  }

  void _notifyListeners() {
    if (!_isDisposed) notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
