import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/entities/student.dart';
import 'auth_state.dart';

// ════════════════════════════════════════════════════════════════════════════
// DEPENDENCY PROVIDERS
// These provide instances through the dependency chain.
// To switch from mock → real API, only change authRemoteDataSourceProvider.
// ════════════════════════════════════════════════════════════════════════════

/// Provides the data source. Swap MockAuthRemoteDataSource for your real
/// HTTP data source here when the backend is ready.
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return MockAuthRemoteDataSource();
  // FUTURE: return RealAuthRemoteDataSource(dioClient: ref.watch(dioProvider));
});

/// Provides the repository implementation.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider));
});

/// Provides the login use case.
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

/// Provides the logout use case.
final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.watch(authRepositoryProvider));
});

// ════════════════════════════════════════════════════════════════════════════
// AUTH NOTIFIER & PROVIDER
// ════════════════════════════════════════════════════════════════════════════

/// The main auth provider. UI widgets watch this to react to auth state changes.
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    loginUseCase: ref.watch(loginUseCaseProvider),
    logoutUseCase: ref.watch(logoutUseCaseProvider),
  );
});

/// A convenience provider for quick access to the authenticated student.
/// Returns null when the user is not authenticated.
final currentStudentProvider = Provider<Student?>((ref) {
  final authState = ref.watch(authProvider);
  return switch (authState) {
    AuthAuthenticated(:final student) => student,
    _ => null,
  };
});

/// True when the user is currently authenticated.
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider) is AuthAuthenticated;
});

// ════════════════════════════════════════════════════════════════════════════
// AUTH NOTIFIER
// ════════════════════════════════════════════════════════════════════════════

class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;

  AuthNotifier({
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
  })  : _loginUseCase = loginUseCase,
        _logoutUseCase = logoutUseCase,
        super(const AuthInitial());

  // ── Login ──────────────────────────────────────────────────────────────────

  /// Attempts to authenticate the student with the given [studentId].
  Future<void> login(String studentId) async {
    // Guard: prevent double submissions
    if (state is AuthLoading) return;

    state = const AuthLoading();

    final result = await _loginUseCase(studentId);

    result.when(
      onSuccess: (student) => state = AuthAuthenticated(student),
      onFailure: (failure) => state = AuthError(failure.message),
    );
  }

  // ── Logout ─────────────────────────────────────────────────────────────────

  /// Signs out the current student and clears the session.
  Future<void> logout() async {
    state = const AuthLoading();

    final result = await _logoutUseCase();

    result.when(
      onSuccess: (_) => state = const AuthUnauthenticated(),
      onFailure: (failure) {
        // Even on logout failure, clear local state for security
        state = const AuthUnauthenticated();
      },
    );
  }

  // ── Clear Error ────────────────────────────────────────────────────────────

  /// Resets the auth state back to [AuthInitial].
  /// Call this when the user starts typing again after an error.
  void clearError() {
    if (state is AuthError) {
      state = const AuthInitial();
    }
  }
}
