// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:neuralcash/widgets/loading_screen.dart';

void main() {
  testWidgets('Loading screen shows label', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: LoadingScreen(label: 'Loading profile...')),
    );
    expect(find.text('Loading profile...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
