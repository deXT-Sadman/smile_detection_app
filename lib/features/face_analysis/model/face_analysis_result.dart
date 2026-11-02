import 'package:flutter/widgets.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceAnalysisResult {
  const FaceAnalysisResult({
    required this.imagePath,
    required this.imageSize,
    required this.faces,
  });

  static const smileThreshold = 0.7;

  final String imagePath;
  final Size imageSize;
  final List<Face> faces;

  int get totalFaces => faces.length;

  int get smilingFaces => faces
      .where((face) => (face.smilingProbability ?? 0) >= smileThreshold)
      .length;

  int get smilingPercentage =>
      totalFaces == 0 ? 0 : (smilingFaces / totalFaces * 100).round();
}
