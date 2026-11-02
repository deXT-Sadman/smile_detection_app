import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import 'face_analysis_widgets.dart';

class FaceImagePreview extends StatelessWidget {
  const FaceImagePreview({
    required this.imagePath,
    required this.faces,
    required this.imageSize,
    required this.isAnalyzing,
    required this.errorMessage,
    super.key,
  });

  final String imagePath;
  final List<Face> faces;
  final Size? imageSize;
  final bool isAnalyzing;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeading('Image preview', Icons.image_outlined),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Container(
            height: 320,
            width: double.infinity,
            color: const Color(0xFFE9EFED),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.file(
                  File(imagePath),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Text('Unable to display this image.'),
                  ),
                ),
                if (imageSize case final size?)
                  CustomPaint(
                    painter: FaceBoundsPainter(imageSize: size, faces: faces),
                  ),
                if (isAnalyzing)
                  ColoredBox(
                    color: Colors.black.withValues(alpha: 0.32),
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(height: 12),
                          Text(
                            'Analyzing faces…',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (errorMessage != null) ...[
          const SizedBox(height: 10),
          Text(
            errorMessage!,
            style: const TextStyle(color: Color(0xFFB3261E), fontSize: 13),
          ),
        ],
      ],
    );
  }
}

class EmptyImagePreview extends StatelessWidget {
  const EmptyImagePreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 210,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDCE7E3)),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: const BoxDecoration(
                color: Color(0xFFF0F6F4),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.image_search_outlined,
                size: 30,
                color: faceAnalysisAccent,
              ),
            ),
            const SizedBox(height: 13),
            const Text(
              'Your photo will appear here',
              style: TextStyle(
                color: Color(0xFF50625E),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading(this.title, this.icon);

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 19, color: faceAnalysisAccent),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF173330),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class FaceBoundsPainter extends CustomPainter {
  const FaceBoundsPainter({required this.imageSize, required this.faces});

  final Size imageSize;
  final List<Face> faces;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = (size.width / imageSize.width)
        .clamp(0.0, size.height / imageSize.height)
        .toDouble();
    final offset = Offset(
      (size.width - imageSize.width * scale) / 2,
      (size.height - imageSize.height * scale) / 2,
    );
    final paint = Paint()
      ..color = const Color(0xFF38E0B0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    for (var index = 0; index < faces.length; index++) {
      final bounds = faces[index].boundingBox;
      final rect = Rect.fromLTRB(
        bounds.left * scale + offset.dx,
        bounds.top * scale + offset.dy,
        bounds.right * scale + offset.dx,
        bounds.bottom * scale + offset.dy,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(8)),
        paint,
      );
      final label = TextPainter(
        text: TextSpan(
          text: 'Face ${index + 1}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final labelRect = Rect.fromLTWH(
        rect.left,
        (rect.top - label.height - 8).clamp(0.0, size.height),
        label.width + 12,
        label.height + 6,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(labelRect, const Radius.circular(5)),
        Paint()..color = faceAnalysisAccent,
      );
      label.paint(canvas, labelRect.topLeft + const Offset(6, 3));
    }
  }

  @override
  bool shouldRepaint(covariant FaceBoundsPainter oldDelegate) =>
      oldDelegate.imageSize != imageSize || oldDelegate.faces != faces;
}
