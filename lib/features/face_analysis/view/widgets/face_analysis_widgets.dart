import 'package:flutter/material.dart';

const faceAnalysisAccent = Color(0xFF087F73);

class AnalyticsCard extends StatelessWidget {
  const AnalyticsCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    super.key,
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

class FaceInformationCard extends StatelessWidget {
  const FaceInformationCard({
    required this.number,
    required this.probability,
    required this.isSmiling,
    super.key,
  });

  final int number;
  final double probability;
  final bool isSmiling;

  @override
  Widget build(BuildContext context) {
    final statusColor = isSmiling
        ? faceAnalysisAccent
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

class EmptyFacesCard extends StatelessWidget {
  const EmptyFacesCard({required this.message, super.key});

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
