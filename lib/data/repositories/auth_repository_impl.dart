import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/student.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

/// ---------------------------------------------------------------------------
/// Concrete implementation of [AuthRepository].
///
/// Responsibilities:
///  - Call the data source
///  - Catch data-layer exceptions
///  - Convert them into domain Failure objects
///  - Return a typed Result<T> back to the use case
///
/// The domain layer never sees raw exceptions — only Result<T>.
/// ---------------------------------------------------------------------------
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  const AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<Student>> loginWithStudentId(String studentId) async {
    try {
      final studentModel = await _remoteDataSource.loginWithStudentId(studentId);
      return Success(studentModel); // StudentModel IS-A Student (extends it)
    } on AuthException catch (e) {
      return FailureResult(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return FailureResult(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return FailureResult(ServerFailure(e.message));
    } catch (e) {
      return FailureResult(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await _remoteDataSource.logout();
      return const Success(null);
    } on NetworkException catch (e) {
      return FailureResult(NetworkFailure(e.message));
    } catch (e) {
      return FailureResult(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<Student?>> getCurrentStudent() async {
    try {
      final student = await _remoteDataSource.getCurrentStudent();
      return Success(student);
    } catch (e) {
      return FailureResult(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    final result = await getCurrentStudent();
    return result.when(
      onSuccess: (student) => student != null,
      onFailure: (_) => false,
    );
  }
}