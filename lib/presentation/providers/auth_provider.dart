import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isra_fields_booking/data/datasources/auth_remote_datasource.dart';
import 'package:isra_fields_booking/data/repositories/auth_repository_impl.dart';
import 'package:isra_fields_booking/domain/entities/student.dart';
import 'package:isra_fields_booking/domain/repositories/auth_repository.dart';
import 'package:isra_fields_booking/domain/usecases/login_usecase.dart';
import 'package:isra_fields_booking/domain/usecases/logout_usecase.dart';
import 'package:isra_fields_booking/core/utils/result.dart';
import 'package:isra_fields_booking/presentation/providers/auth_state.dart';

// ── Dependency Providers ──────────────────────────────────────────────────────

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return MockAuthRemoteDataSource();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider));
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.watch(authRepositoryProvider));
});

// ── Main Auth Provider ────────────────────────────────────────────────────────

final authProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    loginUseCase: ref.watch(loginUseCaseProvider),
    logoutUseCase: ref.watch(logoutUseCaseProvider),
  );
});

// ── Convenience Providers ─────────────────────────────────────────────────────

final currentStudentProvider = Provider<Student?>((ref) {
  final state = ref.watch(authProvider);
  if (state is AuthAuthenticated) return state.student;
  return null;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider) is AuthAuthenticated;
});

// ── Auth Notifier ─────────────────────────────────────────────────────────────

class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;

  AuthNotifier({
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
  })  : _loginUseCase = loginUseCase,
        _logoutUseCase = logoutUseCase,
        super(const AuthInitial());

  Future<void> login(String studentId) async {
    if (state is AuthLoading) return;

    state = const AuthLoading();

    final result = await _loginUseCase(studentId);

    result.when(
      onSuccess: (student) => state = AuthAuthenticated(student),
      onFailure: (failure) => state = AuthError(failure.message),
    );
  }

  Future<void> logout() async {
    state = const AuthLoading();
    await _logoutUseCase();
    state = const AuthUnauthenticated();
  }

  void clearError() {
    if (state is AuthError) {
      state = const AuthInitial();
    }
  }
}