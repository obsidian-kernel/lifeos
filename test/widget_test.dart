import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/app/app.dart';

void main() {
  testWidgets('App shell renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: LifeOSApp(),
      ),
    );
    // Verify the app renders at least one widget
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}