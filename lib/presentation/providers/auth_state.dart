import 'package:equatable/equatable.dart';
import '../../domain/entities/student.dart';

/// ---------------------------------------------------------------------------
/// Sealed class representing every possible state of the Auth flow.
///
/// Using a sealed class (instead of just booleans) means the UI is forced
/// to handle every state explicitly — no missed cases.
/// ---------------------------------------------------------------------------
sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any action has been taken.
final class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Authentication request is in flight.
final class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Student successfully authenticated.
final class AuthAuthenticated extends AuthState {
  final Student student;

  const AuthAuthenticated(this.student);

  @override
  List<Object?> get props => [student];
}

/// Authentication failed — holds a human-readable message for the UI.
final class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Student has logged out — session cleared.
final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}