import 'package:equatable/equatable.dart';

/// ---------------------------------------------------------------------------
/// Failure classes represent domain-level errors returned up the call stack.
/// UI layers react to Failure types, NOT raw exceptions.
/// ---------------------------------------------------------------------------
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];

  @override
  String toString() => message;
}

// ── Auth Failures ─────────────────────────────────────────────────────────────

/// Thrown when student ID is not found or credentials are invalid.
class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed. Please check your Student ID.']);
}

/// Thrown when the session has expired.
class SessionExpiredFailure extends Failure {
  const SessionExpiredFailure([super.message = 'Your session has expired. Please log in again.']);
}

/// Thrown when student is not authorized (e.g., suspended account).
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'You are not authorized to access this resource.']);
}

// ── Network Failures ──────────────────────────────────────────────────────────

/// Thrown when there is no internet connection.
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection. Please check your network.']);
}

/// Thrown when the server returns an unexpected response.
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error. Please try again later.']);
}

/// Thrown when the request times out.
class TimeoutFailure extends Failure {
  const TimeoutFailure([super.message = 'Request timed out. Please try again.']);
}

// ── Validation Failures ───────────────────────────────────────────────────────

/// Thrown when input validation fails on the domain level.
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

// ── Reservation Failures ──────────────────────────────────────────────────────

/// Thrown when the selected time slot is no longer available.
class SlotUnavailableFailure extends Failure {
  const SlotUnavailableFailure([super.message = 'This time slot is no longer available.']);
}

/// Thrown when a student already has an active reservation.
class DuplicateReservationFailure extends Failure {
  const DuplicateReservationFailure([super.message = 'You already have an active reservation.']);
}

// ── Unknown Failure ───────────────────────────────────────────────────────────

/// Catch-all for unexpected errors.
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'An unexpected error occurred. Please try again.']);
}