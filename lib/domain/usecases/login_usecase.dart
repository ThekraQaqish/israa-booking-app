import '../../core/errors/failures.dart';
import '../../core/utils/result.dart';
import '../../core/utils/validators.dart';
import '../entities/student.dart';
import '../repositories/auth_repository.dart';

/// ---------------------------------------------------------------------------
/// LoginUseCase encapsulates the login business logic.
///
/// Responsibilities:
///  - Validate the student ID format before hitting the repository
///  - Delegate to the AuthRepository for actual authentication
///  - Return a typed Result<Student>
///
/// The use case is the single entry point for the login action.
/// ---------------------------------------------------------------------------
class LoginUseCase {
  final AuthRepository _authRepository;

  const LoginUseCase(this._authRepository);

  Future<Result<Student>> call(String studentId) async {
    // 1. Domain-level validation before any network call
    final validationError = AppValidators.validateStudentId(studentId);
    if (validationError != null) {
      return FailureResult(ValidationFailure(validationError));
    }

    // 2. Delegate to repository
    return _authRepository.loginWithStudentId(studentId.trim());
  }
}