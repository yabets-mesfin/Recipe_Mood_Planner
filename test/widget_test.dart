import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_mood_planner/main.dart';

void main() {
  testWidgets('Recipe Mood Planner app loads correctly',
      (WidgetTester tester) async {
    // Build app using the correct root widget
    await tester.pumpWidget(const RecipeMoodPlannerApp());

    // Wait for all frames to settle
    await tester.pumpAndSettle();

    // Basic checks: app loads bottom navigation
    expect(find.byIcon(Icons.explore_outlined), findsOneWidget);
    expect(find.byIcon(Icons.book_outlined), findsOneWidget);
  });
}
