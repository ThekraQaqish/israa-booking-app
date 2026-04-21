import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:isra_fields_booking/core/constants/route_constants.dart';
import 'package:isra_fields_booking/presentation/providers/auth_provider.dart';
import 'package:isra_fields_booking/presentation/providers/auth_state.dart';
import 'package:isra_fields_booking/presentation/screens/login/login_screen.dart';
import 'package:isra_fields_booking/presentation/screens/home/home_screen.dart';
import 'package:isra_fields_booking/presentation/screens/splash/splash_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);

  return GoRouter(
    initialLocation: RouteConstants.splash,
    refreshListenable: notifier,
    debugLogDiagnostics: false,
    redirect: (BuildContext context, GoRouterState state) {
      final authState = ref.read(authProvider);
      final isOnSplash = state.matchedLocation == RouteConstants.splash;
      final isOnLogin = state.matchedLocation == RouteConstants.login;
      final isAuthenticated = authState is AuthAuthenticated;

      if (isOnSplash) return null;
      if (!isAuthenticated && !isOnLogin) return RouteConstants.login;
      if (isAuthenticated && isOnLogin) return RouteConstants.home;
      return null;
    },
    routes: [
      GoRoute(
        path: RouteConstants.splash,
        name: 'splash',
        pageBuilder: (context, state) => _fadePage(
          key: state.pageKey,
          child: const SplashScreen(),
        ),
      ),
      GoRoute(
        path: RouteConstants.login,
        name: 'login',
        pageBuilder: (context, state) => _slidePage(
          key: state.pageKey,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: RouteConstants.home,
        name: 'home',
        pageBuilder: (context, state) => _fadePage(
          key: state.pageKey,
          child: const HomeScreen(),
        ),
        // Add sub-routes here later:
        // routes: [ GoRoute(path: 'fields', ...) ]
      ),
    ],
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

CustomTransitionPage<void> _fadePage({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, _, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}

CustomTransitionPage<void> _slidePage({
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

class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(Ref ref) {
    ref.listen(authProvider, (_, __) => notifyListeners());
  }
}