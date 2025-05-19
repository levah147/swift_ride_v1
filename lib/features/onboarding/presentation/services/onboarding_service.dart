import 'package:hive_flutter/hive_flutter.dart';

class OnboardingService {
  static const String _boxName = 'app_settings';
  static const String _onboardingCompletedKey = 'onboarding_completed';
  
  Box? _box;
  bool _isInitialized = false;
  
  // Initialize the service
  Future<void> init() async {
    if (!_isInitialized) {
      _box = await Hive.openBox(_boxName);
      _isInitialized = true;
    }
  }
  
  // Check if onboarding is completed
  bool isOnboardingCompleted() {
    // If box is not initialized yet, default to false (show onboarding)
    if (_box == null || !_isInitialized) {
      return false;
    }
    return _box!.get(_onboardingCompletedKey, defaultValue: false);
  }
  
  // Set onboarding completed status
  Future<void> setOnboardingCompleted(bool completed) async {
    if (_box == null || !_isInitialized) {
      await init();
    }
    await _box?.put(_onboardingCompletedKey, completed);
  }
}