import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/constants/route_constants.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/registration_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/onboarding/presentation/providers/onboarding_provider.dart';
import 'features/onboarding/presentation/screens/onboarding_screen.dart';
import 'features/splash/presentation/screens/splash_screen.dart';

class RideHailingApp extends ConsumerWidget {
  const RideHailingApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = GoRouter(
      initialLocation: RouteConstants.splash,
      debugLogDiagnostics: true,
      refreshListenable: GoRouterRefreshStream(
        ref.watch(authProvider.notifier).stream,
      ),
      redirect: (context, state) {
        // No redirects from splash screen - let it handle its own navigation
        if (state.uri.toString() == RouteConstants.splash) {
          return null;
        }
        
        final authState = ref.read(authProvider);
        final isLoggedIn = authState.isAuthenticated;
        
        // Use safe access to onboarding provider
        final onboardingService = ref.read(onboardingServiceProvider);
        final isOnboardingComplete = onboardingService.isOnboardingCompleted();
        
        final isOnboarding = state.uri.toString() == RouteConstants.onboarding;
        final isLoginRoute = state.uri.toString() == RouteConstants.login;
        final isRegisterRoute = state.uri.toString() == RouteConstants.register;
        
        // If not logged in and not on auth routes, redirect to appropriate screen
        if (!isLoggedIn) {
          if (!isOnboardingComplete && !isOnboarding) {
            return RouteConstants.onboarding;
          }
          
          if (!isLoginRoute && !isRegisterRoute && !isOnboarding) {
            return RouteConstants.login;
          }
          
          return null;
        }
        
        // If logged in and on auth routes, redirect to home
        if (isLoggedIn && (isLoginRoute || isRegisterRoute || isOnboarding)) {
          return RouteConstants.home;
        }
        
        return null;
      },
      routes: [
        GoRoute(
          path: RouteConstants.splash,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: RouteConstants.onboarding,
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: RouteConstants.login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: RouteConstants.register,
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: RouteConstants.home,
          builder: (context, state) => const HomeScreen(),
        ),
        // Add more routes as needed
      ],
    );

    return MaterialApp.router(
      title: 'Ride Hailing App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}

// Helper class to convert StateNotifier to Listenable for GoRouter
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}