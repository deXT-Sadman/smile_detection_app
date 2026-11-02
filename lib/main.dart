import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const FaceAnalysisApp());
}

class FaceAnalysisApp extends StatelessWidget {
  const FaceAnalysisApp({super.key});

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF087F73);
    return MaterialApp(
      title: 'Face Detection & Smile Analysis',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: accent,
          surface: const Color(0xFFF7F9F8),
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F9F8),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF7F9F8),
          foregroundColor: Color(0xFF173330),
          surfaceTintColor: Colors.transparent,
        ),
      ),
      home: const FaceAnalysisPage(),
    );
  }
}

class FaceAnalysisPage extends StatefulWidget {
  const FaceAnalysisPage({super.key});

  @override
  State<FaceAnalysisPage> createState() => _FaceAnalysisPageState();
}

class _FaceAnalysisPageState extends State<FaceAnalysisPage> {
  static const _accent = Color(0xFF087F73);
  static const _smileThreshold = 0.7;

  final ImagePicker _imagePicker = ImagePicker();
  XFile? _selectedImage;
  Size? _imageSize;
  List<Face> _faces = [];
  bool _isAnalyzing = false;
  String? _errorMessage;

  int get _smilingCount => _faces
      .where((face) => (face.smilingProbability ?? 0) >= _smileThreshold)
      .length;

  int get _smilingPercentage =>
      _faces.isEmpty ? 0 : (_smilingCount / _faces.length * 100).round();

  Future<void> _selectImage() async {
    try {
      final image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image == null || !mounted) return;

      setState(() {
        _selectedImage = image;
        _imageSize = null;
        _faces = [];
        _isAnalyzing = true;
        _errorMessage = null;
      });

      final codec = await ui.instantiateImageCodec(
        await File(image.path).readAsBytes(),
      );
      final frame = await codec.getNextFrame();
      final imageSize = Size(
        frame.image.width.toDouble(),
        frame.image.height.toDouble(),
      );
      frame.image.dispose();
      codec.dispose();

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

      if (!mounted) return;
      setState(() {
        _imageSize = imageSize;
        _faces = faces;
        _isAnalyzing = false;
      });
    } catch (error) {
      debugPrint('Face image analysis failed: $error');
      if (!mounted) return;
      setState(() {
        _isAnalyzing = false;
        _errorMessage = 'We couldn’t analyze this image. Please try another.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to open or analyze that image. Please try again.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: const Text(
          'Face Detection & Smile Analysis',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            _buildIntro(),
            const SizedBox(height: 22),
            _buildUploadButton(),
            if (_selectedImage != null) ...[
              const SizedBox(height: 22),
              _buildImagePreview(),
              const SizedBox(height: 24),
              _buildAnalytics(),
            ] else ...[
              const SizedBox(height: 22),
              _buildEmptyPreview(),
              const SizedBox(height: 22),
              _buildAnalytics(),
            ],
            const SizedBox(height: 28),
            _buildFaceInformation(),
          ],
        ),
      ),
    );
  }

  Widget _buildIntro() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFE2F2EE),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.face_retouching_natural_rounded,
            color: _accent,
            size: 26,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _selectedImage == null ? 'See who’s smiling.' : 'Your image analysis',
          style: const TextStyle(
            color: Color(0xFF173330),
            fontSize: 27,
            fontWeight: FontWeight.w800,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          'Upload a photo to detect faces and discover the smiles in it.',
          style: TextStyle(
            color: Colors.blueGrey.shade600,
            fontSize: 14,
            height: 1.45,
          ),
        ),
      ],
    );
  }

  Widget _buildUploadButton() {
    return SizedBox(
      height: 54,
      child: FilledButton.icon(
        onPressed: _isAnalyzing ? null : _selectImage,
        icon: Icon(
          _selectedImage == null
              ? Icons.add_photo_alternate_outlined
              : Icons.refresh,
        ),
        label: Text(
          _selectedImage == null ? 'Upload image' : 'Upload another image',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: _accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyPreview() {
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
                color: _accent,
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

  Widget _buildImagePreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeading('Image preview', Icons.image_outlined),
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
                  File(_selectedImage!.path),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Text('Unable to display this image.'),
                  ),
                ),
                if (_imageSize case final imageSize?)
                  CustomPaint(
                    painter: _FaceBoundsPainter(
                      imageSize: imageSize,
                      faces: _faces,
                    ),
                  ),
                if (_isAnalyzing)
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
        if (_errorMessage != null) ...[
          const SizedBox(height: 10),
          Text(
            _errorMessage!,
            style: const TextStyle(color: Color(0xFFB3261E), fontSize: 13),
          ),
        ],
      ],
    );
  }

  Widget _buildAnalytics() {
    return Row(
      children: [
        Expanded(
          child: _AnalyticsCard(
            label: 'Total faces',
            value: _isAnalyzing ? '—' : '${_faces.length}',
            icon: Icons.face_6_outlined,
            color: _accent,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _AnalyticsCard(
            label: 'Smiling',
            value: _isAnalyzing ? '—' : '$_smilingPercentage%',
            icon: Icons.sentiment_satisfied_alt_rounded,
            color: const Color(0xFFCE8A24),
          ),
        ),
      ],
    );
  }

  Widget _buildFaceInformation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _sectionHeading(
                'Individual faces',
                Icons.groups_2_outlined,
              ),
            ),
            if (!_isAnalyzing)
              Text(
                '${_faces.length} found',
                style: TextStyle(
                  color: Colors.blueGrey.shade500,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (_isAnalyzing)
          const _EmptyFacesCard(message: 'Face details will appear shortly.')
        else if (_faces.isEmpty)
          _EmptyFacesCard(
            message: _selectedImage == null
                ? 'Upload an image to see individual face details.'
                : 'No faces detected in this image.',
          )
        else
          ...List.generate(_faces.length, (index) {
            final face = _faces[index];
            final probability = face.smilingProbability ?? 0;
            final isSmiling = probability >= _smileThreshold;
            return _FaceInformationCard(
              number: index + 1,
              probability: probability,
              isSmiling: isSmiling,
            );
          }),
      ],
    );
  }

  Widget _sectionHeading(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 19, color: _accent),
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

class _AnalyticsCard extends StatelessWidget {
  const _AnalyticsCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE7EEEB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 21, color: color),
          const SizedBox(height: 14),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.blueGrey.shade600,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _FaceInformationCard extends StatelessWidget {
  const _FaceInformationCard({
    required this.number,
    required this.probability,
    required this.isSmiling,
  });

  final int number;
  final double probability;
  final bool isSmiling;

  @override
  Widget build(BuildContext context) {
    final statusColor = isSmiling
        ? const Color(0xFF087F73)
        : const Color(0xFF687873);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE7EEEB)),
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              isSmiling
                  ? Icons.sentiment_satisfied_alt_rounded
                  : Icons.face_outlined,
              color: statusColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Face $number',
                  style: const TextStyle(
                    color: Color(0xFF173330),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isSmiling ? 'Smiling' : 'Not smiling',
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${(probability * 100).round()}%',
            style: const TextStyle(
              color: Color(0xFF173330),
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'smile',
            style: TextStyle(color: Colors.blueGrey.shade500, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _EmptyFacesCard extends StatelessWidget {
  const _EmptyFacesCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE7EEEB)),
      ),
      child: Text(
        message,
        style: TextStyle(color: Colors.blueGrey.shade600, fontSize: 13),
      ),
    );
  }
}

class _FaceBoundsPainter extends CustomPainter {
  const _FaceBoundsPainter({required this.imageSize, required this.faces});

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

    for (final face in faces) {
      final bounds = face.boundingBox;
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
          text: 'Face ${faces.indexOf(face) + 1}',
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
        Paint()..color = const Color(0xFF087F73),
      );
      label.paint(canvas, labelRect.topLeft + const Offset(6, 3));
    }
  }

  @override
  bool shouldRepaint(covariant _FaceBoundsPainter oldDelegate) =>
      oldDelegate.imageSize != imageSize || oldDelegate.faces != faces;
}
