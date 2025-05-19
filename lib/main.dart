import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/services/service_locator.dart';
import 'features/onboarding/data/services/onboarding_service.dart';
import 'features/onboarding/presentation/providers/onboarding_provider.dart';

Future<void> main() async {
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Set preferred orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    // Initialize services
    await _initializeServices();
    
    // Create and initialize the onboarding service
    final onboardingService = OnboardingService();
    await onboardingService.init();
    
    // Run app
    runApp(
      ProviderScope(
        overrides: [
          // Provide the initialized onboarding service
          onboardingServiceProvider.overrideWithValue(onboardingService),
        ],
        child: const RideHailingApp(),
      ),
    );
  }, (error, stack) {
    if (kDebugMode) {
      // Print errors in debug mode
      print('ERROR: $error');
      print('STACK: $stack');
    }
  });
}

Future<void> _initializeServices() async {
  // Load environment variables (if available)
  try {
    await dotenv.load();
  } catch (e) {
    debugPrint('No .env file found. Using default configuration.');
    // Set default values if needed
  }

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Register Hive adapters
  // TODO0: Register your custom Hive adapters here

  // Initialize service locator
  await setupServiceLocator();
}