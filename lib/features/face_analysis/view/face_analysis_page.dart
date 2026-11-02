import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../controller/face_analysis_controller.dart';
import '../model/face_analysis_result.dart';
import 'widgets/face_analysis_widgets.dart';
import 'widgets/face_image_preview.dart';

class FaceAnalysisPage extends StatefulWidget {
  const FaceAnalysisPage({super.key});

  @override
  State<FaceAnalysisPage> createState() => _FaceAnalysisPageState();
}

class _FaceAnalysisPageState extends State<FaceAnalysisPage> {
  late final FaceAnalysisController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FaceAnalysisController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
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
                if (_controller.selectedImagePath case final imagePath?) ...[
                  const SizedBox(height: 22),
                  FaceImagePreview(
                    imagePath: imagePath,
                    faces: _controller.result?.faces ?? const <Face>[],
                    imageSize: _controller.result?.imageSize,
                    isAnalyzing: _controller.isAnalyzing,
                    errorMessage: _controller.errorMessage,
                  ),
                  const SizedBox(height: 24),
                ] else ...[
                  const SizedBox(height: 22),
                  const EmptyImagePreview(),
                  const SizedBox(height: 22),
                ],
                _buildAnalytics(_controller.result, _controller.isAnalyzing),
                const SizedBox(height: 28),
                _buildFaceInformation(
                  _controller.result,
                  _controller.isAnalyzing,
                  _controller.selectedImagePath != null,
                ),
              ],
            ),
          ),
        );
      },
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
            color: faceAnalysisAccent,
            size: 26,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _controller.selectedImagePath == null
              ? 'See who’s smiling.'
              : 'Your image analysis',
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
    final hasImage = _controller.selectedImagePath != null;
    return SizedBox(
      height: 54,
      child: FilledButton.icon(
        onPressed: _controller.isAnalyzing ? null : _controller.selectImage,
        icon: Icon(
          hasImage ? Icons.refresh : Icons.add_photo_alternate_outlined,
        ),
        label: Text(
          hasImage ? 'Upload another image' : 'Upload image',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: faceAnalysisAccent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildAnalytics(FaceAnalysisResult? result, bool isAnalyzing) {
    return Row(
      children: [
        Expanded(
          child: AnalyticsCard(
            label: 'Total faces',
            value: isAnalyzing ? '—' : '${result?.totalFaces ?? 0}',
            icon: Icons.face_6_outlined,
            color: faceAnalysisAccent,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AnalyticsCard(
            label: 'Smiling',
            value: isAnalyzing ? '—' : '${result?.smilingPercentage ?? 0}%',
            icon: Icons.sentiment_satisfied_alt_rounded,
            color: const Color(0xFFCE8A24),
          ),
        ),
      ],
    );
  }

  Widget _buildFaceInformation(
    FaceAnalysisResult? result,
    bool isAnalyzing,
    bool hasImage,
  ) {
    final faces = result?.faces ?? const <Face>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: _SectionHeading(
                'Individual faces',
                Icons.groups_2_outlined,
              ),
            ),
            if (!isAnalyzing)
              Text(
                '${faces.length} found',
                style: TextStyle(
                  color: Colors.blueGrey.shade500,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (isAnalyzing)
          const EmptyFacesCard(message: 'Face details will appear shortly.')
        else if (faces.isEmpty)
          EmptyFacesCard(
            message: hasImage
                ? 'No faces detected in this image.'
                : 'Upload an image to see individual face details.',
          )
        else
          ...List.generate(faces.length, (index) {
            final probability = faces[index].smilingProbability ?? 0;
            return FaceInformationCard(
              number: index + 1,
              probability: probability,
              isSmiling: probability >= FaceAnalysisResult.smileThreshold,
            );
          }),
      ],
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
