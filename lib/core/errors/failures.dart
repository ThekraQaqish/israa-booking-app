import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];

  @override
  String toString() => message;
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed. Please check your Student ID.']);
}

class SessionExpiredFailure extends Failure {
  const SessionExpiredFailure([super.message = 'Your session has expired. Please log in again.']);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'You are not authorized to access this resource.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection. Please check your network.']);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error. Please try again later.']);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure([super.message = 'Request timed out. Please try again.']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class SlotUnavailableFailure extends Failure {
  const SlotUnavailableFailure([super.message = 'This time slot is no longer available.']);
}

class DuplicateReservationFailure extends Failure {
  const DuplicateReservationFailure([super.message = 'You already have an active reservation.']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'An unexpected error occurred. Please try again.']);
}