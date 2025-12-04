// NeuroSpark Widget Tests

import 'package:flutter_test/flutter_test.dart';
import 'package:neuro_spark/main.dart';

void main() {
  testWidgets('App initializes successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const NeuroSparkApp());

    // Verify app initializes
    expect(find.byType(NeuroSparkApp), findsOneWidget);
  });
}
