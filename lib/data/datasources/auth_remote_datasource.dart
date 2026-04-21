import 'package:isra_fields_booking/core/constants/app_constants.dart';
import 'package:isra_fields_booking/core/errors/exceptions.dart';
import 'package:isra_fields_booking/data/models/student_model.dart';

abstract class AuthRemoteDataSource {
  Future<StudentModel> loginWithStudentId(String studentId);
  Future<void> logout();
  Future<StudentModel?> getCurrentStudent();
}

class MockAuthRemoteDataSource implements AuthRemoteDataSource {
  StudentModel? _sessionStudent;

  static final Map<String, Map<String, dynamic>> _mockDatabase = {
    '2021100001': {
      'student_id': '2021100001',
      'name': 'Ahmad Al-Khalidi',
      'email': '2021100001@isra.edu.jo',
      'department': 'Computer Science',
      'year': '4th Year',
      'is_active': true,
    },
    '2021100002': {
      'student_id': '2021100002',
      'name': 'Sara Al-Mansouri',
      'email': '2021100002@isra.edu.jo',
      'department': 'Software Engineering',
      'year': '4th Year',
      'is_active': true,
    },
    '2022100010': {
      'student_id': '2022100010',
      'name': 'Omar Al-Rashid',
      'email': '2022100010@isra.edu.jo',
      'department': 'Civil Engineering',
      'year': '3rd Year',
      'is_active': true,
    },
    '2023100099': {
      'student_id': '2023100099',
      'name': 'Lina Al-Barakat',
      'email': '2023100099@isra.edu.jo',
      'department': 'Business Administration',
      'year': '2nd Year',
      'is_active': true,
    },
    '2020100050': {
      'student_id': '2020100050',
      'name': 'Khaled Al-Nasser',
      'email': '2020100050@isra.edu.jo',
      'department': 'Pharmacy',
      'year': '5th Year',
      'is_active': false,
    },
  };

  @override
  Future<StudentModel> loginWithStudentId(String studentId) async {
    await Future.delayed(AppConstants.mockAuthDelay);

    final studentData = _mockDatabase[studentId];

    if (studentData == null) {
      throw const AuthException(
        'Student ID not found. Please check your ID and try again.',
      );
    }

    final student = StudentModel.fromJson(studentData);

    if (!student.isActive) {
      throw const AuthException(
        'Your account has been suspended. Please contact the university administration.',
      );
    }

    _sessionStudent = student;
    return student;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _sessionStudent = null;
  }

  @override
  Future<StudentModel?> getCurrentStudent() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _sessionStudent;
  }
}