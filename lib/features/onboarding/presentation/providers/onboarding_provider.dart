import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/onboarding_service.dart';

final onboardingServiceProvider = Provider<OnboardingService>((ref) {
  return OnboardingService();
});

final onboardingCompletedProvider = Provider<bool>((ref) {
  final onboardingService = ref.watch(onboardingServiceProvider);
  return onboardingService.isOnboardingCompleted();
});