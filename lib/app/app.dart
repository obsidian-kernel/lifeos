import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../shared/providers/core_providers.dart';
import 'router.dart';

/// Root application widget.
///
/// Responsibilities:
/// - Apply theme
/// - Wire router
/// - Trigger notification initialization on startup
/// - ProviderScope is in main.dart — not here. App.dart knows nothing
///   about the DI container. It only consumes providers.
class LifeOSApp extends ConsumerWidget {
  const LifeOSApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize notifications at startup.
    // Errors are handled inside the provider — app does not crash on failure.
    ref.watch(initializeNotificationsProvider);

    return MaterialApp.router(
      title: 'LifeOS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: appRouter,
    );
  }
}