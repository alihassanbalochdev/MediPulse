import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medipulse_medical/core/router/app_shell.dart';
import 'package:medipulse_medical/core/router/route_guards.dart';
import 'package:medipulse_medical/features/auth/presentation/sign_in_screen.dart';
import 'package:medipulse_medical/features/dashboard/presentation/dashboard_screen.dart';
import 'package:medipulse_medical/features/medications/presentation/cabinet_screen.dart';
import 'package:medipulse_medical/features/medications/presentation/history_screen.dart';
import 'package:medipulse_medical/features/medications/presentation/today_screen.dart';
import 'package:medipulse_medical/features/onboarding/presentation/onboarding_screen.dart';
import 'package:medipulse_medical/features/onboarding/presentation/providers/onboarding_providers.dart';
import 'package:medipulse_medical/features/onboarding/presentation/splash_screen.dart';
import 'package:medipulse_medical/features/profile/presentation/medical_id_editor_screen.dart';
import 'package:medipulse_medical/features/profile/presentation/profile_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final rootKey = GlobalKey<NavigatorState>();

  // The bridge: Riverpod state -> ValueNotifier -> GoRouter.
  // GoRouter can't watch a provider, but it can listen to a Listenable.
  // null = still loading from storage.
  final onboardingDone = ValueNotifier<bool?>(null);
  ref.listen(onboardingProvider, (previous, next) {
    onboardingDone.value = switch (next) {
      AsyncData(:final value) => value,
      AsyncError() => false, // can't read the flag: show onboarding
      _ => null,
    };
  }, fireImmediately: true);
  ref.onDispose(onboardingDone.dispose);

  final router = GoRouter(
    navigatorKey: rootKey,
    initialLocation: splashPath,
    refreshListenable: onboardingDone,
    redirect: (context, state) => onboardingRedirect(
      onboardingDone: onboardingDone.value,
      location: state.matchedLocation,
    ),
    routes: [
      GoRoute(path: splashPath, builder: (context, state) => const SplashScreen()),
      GoRoute(
        path: onboardingPath,
        builder: (context, state) => const OnboardingScreen(),
      ),
      // Full screen, above the tab bar
      GoRoute(
        path: '/medical-id',
        parentNavigatorKey: rootKey,
        builder: (context, state) => const MedicalIdEditorScreen(),
      ),
      GoRoute(
        path: '/sign-in',
        parentNavigatorKey: rootKey,
        builder: (context, state) => const SignInScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: homePath, builder: (context, state) => const DashboardScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/today', builder: (context, state) => const TodayScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/cabinet', builder: (context, state) => const CabinetScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/history', builder: (context, state) => const HistoryScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
          ]),
        ],
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});
