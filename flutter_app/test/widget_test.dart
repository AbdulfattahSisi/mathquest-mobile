// MathQuest — basic smoke test
//
// Verifies the app widget builds without errors.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mathquest/main.dart';

void main() {
  testWidgets('App builds without error', (WidgetTester tester) async {
    await tester.pumpWidget(const MathQuestApp());
    // Verify splash or app renders
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
