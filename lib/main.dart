import 'package:flutter/material.dart';

import 'features/face_analysis/view/face_analysis_page.dart';

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
