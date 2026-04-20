import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/route_constants.dart';
import '../presentation/providers/auth_provider.dart';
import '../presentation/providers/auth_state.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/splash/splash_screen.dart';

// ── Future screen imports (uncomment as you build them) ─────────────────────
// import '../presentation/screens/fields/field_list_screen.dart';
// import '../presentation/screens/fields/field_detail_screen.dart';
// import '../presentation/screens/reservation/time_slot_screen.dart';
// import '../presentation/screens/reservation/reservation_history_screen.dart';
// import '../presentation/screens/notifications/notifications_screen.dart';
// import '../presentation/screens/profile/profile_screen.dart';

/// ---------------------------------------------------------------------------
/// AppRouter — centralized GoRouter configuration with auth-aware redirects.
///
/// HOW REDIRECTS WORK:
///   - Splash → always loads first, then navigates based on auth state.
///   - Unauthenticated users hitting a protected route → redirected to /login.
///   - Authenticated users hitting /login → redirected to /home.
/// ---------------------------------------------------------------------------
final appRouterProvider = Provider<GoRouter>((ref) {
  // Listen to auth state changes to trigger router refresh
  final authNotifier = RouterNotifierAdapter(ref);

  return GoRouter(
    initialLocation: RouteConstants.splash,
    refreshListenable: authNotifier,
    debugLogDiagnostics: true, // Set to false for production
    redirect: (BuildContext context, GoRouterState state) {
      final authState = ref.read(authProvider);
      final isOnSplash = state.matchedLocation == RouteConstants.splash;
      final isOnLogin = state.matchedLocation == RouteConstants.login;
      final isAuthenticated = authState is AuthAuthenticated;

      // Let the splash screen handle its own navigation
      if (isOnSplash) return null;

      // Redirect unauthenticated users to login
      if (!isAuthenticated && !isOnLogin) {
        return RouteConstants.login;
      }

      // Redirect already-authenticated users away from login
      if (isAuthenticated && isOnLogin) {
        return RouteConstants.home;
      }

      return null; // No redirect needed
    },
    routes: [
      // ── Splash ─────────────────────────────────────────────────────────────
      GoRoute(
        path: RouteConstants.splash,
        name: 'splash',
        pageBuilder: (context, state) => _fadeTransitionPage(
          key: state.pageKey,
          child: const SplashScreen(),
        ),
      ),

      // ── Auth ───────────────────────────────────────────────────────────────
      GoRoute(
        path: RouteConstants.login,
        name: 'login',
        pageBuilder: (context, state) => _slideTransitionPage(
          key: state.pageKey,
          child: const LoginScreen(),
        ),
      ),

      // ── Main App Shell ─────────────────────────────────────────────────────
      GoRoute(
        path: RouteConstants.home,
        name: 'home',
        pageBuilder: (context, state) => _fadeTransitionPage(
          key: state.pageKey,
          child: const HomeScreen(),
        ),
        routes: [
          // ── Fields (prepared, add screens later) ──────────────────────────
          // GoRoute(
          //   path: 'fields',
          //   name: 'field-list',
          //   builder: (context, state) => const FieldListScreen(),
          //   routes: [
          //     GoRoute(
          //       path: ':fieldId',
          //       name: 'field-detail',
          //       builder: (context, state) => FieldDetailScreen(
          //         fieldId: state.pathParameters['fieldId']!,
          //       ),
          //       routes: [
          //         GoRoute(
          //           path: 'slots',
          //           name: 'time-slots',
          //           builder: (context, state) => TimeSlotScreen(
          //             fieldId: state.pathParameters['fieldId']!,
          //           ),
          //         ),
          //       ],
          //     ),
          //   ],
          // ),

          // ── Reservations ──────────────────────────────────────────────────
          // GoRoute(
          //   path: 'reservations',
          //   name: 'reservation-history',
          //   builder: (context, state) => const ReservationHistoryScreen(),
          //   routes: [
          //     GoRoute(
          //       path: ':reservationId',
          //       name: 'reservation-detail',
          //       builder: (context, state) => ReservationDetailScreen(
          //         reservationId: state.pathParameters['reservationId']!,
          //       ),
          //     ),
          //   ],
          // ),

          // ── Notifications ─────────────────────────────────────────────────
          // GoRoute(
          //   path: 'notifications',
          //   name: 'notifications',
          //   builder: (context, state) => const NotificationsScreen(),
          // ),

          // ── Profile ───────────────────────────────────────────────────────
          // GoRoute(
          //   path: 'profile',
          //   name: 'profile',
          //   builder: (context, state) => const ProfileScreen(),
          // ),
        ],
      ),
    ],

    // ── Error Route ───────────────────────────────────────────────────────
    errorPageBuilder: (context, state) => MaterialPage(
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Page not found',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(state.error?.message ?? 'Unknown route'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go(RouteConstants.home),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
});

// ── Page Transition Helpers ───────────────────────────────────────────────────

CustomTransitionPage<void> _fadeTransitionPage({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, _, child) => FadeTransition(
      opacity: animation,
      child: child,
    ),
  );
}

CustomTransitionPage<void> _slideTransitionPage({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 350),
    transitionsBuilder: (context, animation, _, child) => SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.05),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
      child: FadeTransition(opacity: animation, child: child),
    ),
  );
}

// ── Router Notifier Adapter ───────────────────────────────────────────────────

/// Bridges Riverpod's state changes to GoRouter's [Listenable] system,
/// so the router re-evaluates redirects whenever auth state changes.
class RouterNotifierAdapter extends ChangeNotifier {
  RouterNotifierAdapter(Ref ref) {
    ref.listen(authProvider, (_, __) => notifyListeners());
  }
}