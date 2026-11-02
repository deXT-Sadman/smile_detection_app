import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smile_detection_app/main.dart';

void main() {
  testWidgets('shows the image analysis home screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const FaceAnalysisApp());

    expect(find.text('Face Detection & Smile Analysis'), findsOneWidget);
    expect(find.text('Upload image'), findsOneWidget);
    expect(find.text('Your photo will appear here'), findsOneWidget);
    expect(find.text('Total faces'), findsOneWidget);
    expect(find.text('Smiling'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
    expect(find.text('0%'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Individual faces'),
      250,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('Individual faces'), findsOneWidget);
    expect(
      find.text('Upload an image to see individual face details.'),
      findsOneWidget,
    );
  });
}
