import 'package:isra_fields_booking/core/errors/exceptions.dart';
import 'package:isra_fields_booking/core/errors/failures.dart';
import 'package:isra_fields_booking/core/utils/result.dart';
import 'package:isra_fields_booking/data/datasources/auth_remote_datasource.dart';
import 'package:isra_fields_booking/domain/entities/student.dart';
import 'package:isra_fields_booking/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  const AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<Student>> loginWithStudentId(String studentId) async {
    try {
      final studentModel =
          await _remoteDataSource.loginWithStudentId(studentId);
      return Success(studentModel);
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
      return Success<void>(null);
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
    if (result is Success<Student?>) {
      return result.data != null;
    }
    return false;
  }
}