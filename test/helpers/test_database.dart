import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/core/database/app_database.dart';
import 'package:lifeos/shared/providers/core_providers.dart';

/// Creates a fresh in-memory AppDatabase for each test.
/// Zero I/O. Zero state leakage between tests.
AppDatabase createTestDatabase() => AppDatabase.forTesting();

/// Creates a ProviderContainer with an in-memory test database.
///
/// Usage:
/// ```dart
/// final container = createTestContainer();
/// final db = container.read(appDatabaseProvider);
/// addTearDown(container.dispose);
/// ```
ProviderContainer createTestContainer({
  List<Override> additionalOverrides = const [],
}) {
  final db = createTestDatabase();
  return ProviderContainer(
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
      ...additionalOverrides,
    ],
  );
}

/// Pumps a widget inside a ProviderScope with an in-memory database.
///
/// Usage:
/// ```dart
/// await tester.pumpWithTestScope(child: const MyWidget());
/// ```
extension WidgetTesterTestScope on WidgetTester {
  Future<void> pumpWithTestScope({
    required Widget child,
    List<Override> overrides = const [],
  }) async {
    final db = createTestDatabase();
    await pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          ...overrides,
        ],
        child: MaterialApp(home: child),
      ),
    );
  }
}