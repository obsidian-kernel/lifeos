import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';

Future<void> main() async {
  // Required before any async work in main()
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait on mobile only — desktop has no orientation lock
  // This is handled via MediaQuery in AppShell, not via SystemChrome
  // on desktop. SystemChrome.setPreferredOrientations is Android-specific.

  runApp(
    const ProviderScope(
      // ProviderScope is the outermost widget.
      // Every Riverpod provider resolves within this scope.
      // Do not nest ProviderScopes unless explicitly testing with overrides.
      child: LifeOSApp(),
    ),
  );
}