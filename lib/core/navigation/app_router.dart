import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/otp_verification_screen.dart';
import '../../features/auth/presentation/screens/registration_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/rides/presentation/screens/ride_history_screen.dart';
import '../../features/rides/presentation/screens/ride_tracking_screen.dart';
import '../constants/route_constants.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  // TODO0: Add auth state checking logic
  final isAuthenticated = false;

  return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: RouteConstants.splash,
      debugLogDiagnostics: true,
      routes: [
        // Initial routes
        GoRoute(
          path: RouteConstants.splash,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: RouteConstants.onboarding,
          builder: (context, state) => const OnboardingScreen(),
        ),

        // Auth routes
        GoRoute(
          path: RouteConstants.login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: RouteConstants.register,
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: RouteConstants.verifyOtp,
          builder: (context, state) {
            final phoneNumber = state.uri.queryParameters['phoneNumber'] ?? '';
            return OtpVerificationScreen(phoneNumber: phoneNumber);
          },
        ),

        // Main app shell with bottom navigation
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) {
            return ScaffoldWithBottomNavBar(child: child);
          },
          routes: [
            // Home tab
            GoRoute(
              path: RouteConstants.home,
              builder: (context, state) => const HomeScreen(),
              routes: [
                GoRoute(
                  path: 'ride',
                  builder: (context, state) => const RideTrackingScreen(),
                ),
              ],
            ),

            // Ride history tab
            GoRoute(
              path: RouteConstants.rideHistory,
              builder: (context, state) => const RideHistoryScreen(),
            ),

            // Profile tab
            GoRoute(
              path: RouteConstants.profile,
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
      redirect: (context, state) {
        final location = state.matchedLocation;

        // Move all variable checks before any return
        final isAuthenticated = false;
        final isOnboardingComplete = true;

        final isOnSplash = location == RouteConstants.splash;
        final isOnOnboarding = location == RouteConstants.onboarding;
        final isOnAuthScreens = location == RouteConstants.login ||
            location == RouteConstants.register ||
            location == RouteConstants.verifyOtp;

        // Now it's safe to return early
        if (isOnSplash) return null;

        if (!isOnboardingComplete && !isOnOnboarding) {
          return RouteConstants.onboarding;
        }

        if (!isAuthenticated && !isOnAuthScreens && !isOnOnboarding) {
          return RouteConstants.login;
        }

        if (isAuthenticated && (isOnAuthScreens || isOnOnboarding)) {
          return RouteConstants.home;
        }

        return null;
      });
});

class ScaffoldWithBottomNavBar extends StatelessWidget {
  final Widget child;

  const ScaffoldWithBottomNavBar({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Rides',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith(RouteConstants.home)) {
      return 0;
    }
    if (location.startsWith(RouteConstants.rideHistory)) {
      return 1;
    }
    if (location.startsWith(RouteConstants.profile)) {
      return 2;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        GoRouter.of(context).go(RouteConstants.home);
        break;
      case 1:
        GoRouter.of(context).go(RouteConstants.rideHistory);
        break;
      case 2:
        GoRouter.of(context).go(RouteConstants.profile);
        break;
    }
  }
}
