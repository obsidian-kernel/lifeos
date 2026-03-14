import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Required by media_kit on all platforms before any Player is created.
  MediaKit.ensureInitialized();

  runApp(
    const ProviderScope(
      child: LifeOSApp(),
    ),
  );
}