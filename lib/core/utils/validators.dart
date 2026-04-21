import 'package:isra_fields_booking/core/constants/app_constants.dart';

class AppValidators {
  AppValidators._();

  static String? validateStudentId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Student ID is required.';
    }
    final trimmed = value.trim();
    if (!_isNumericOnly(trimmed)) {
      return 'Student ID must contain numbers only.';
    }
    if (trimmed.length < AppConstants.studentIdLength) {
      return 'Student ID must be exactly ${AppConstants.studentIdLength} digits.';
    }
    if (trimmed.length > AppConstants.studentIdLength) {
      return 'Student ID must be exactly ${AppConstants.studentIdLength} digits.';
    }
    return null;
  }

  static bool isValidStudentId(String value) =>
      validateStudentId(value) == null;

  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required.';
    }
    return null;
  }

  static bool _isNumericOnly(String value) =>
      RegExp(AppConstants.studentIdPattern).hasMatch(value);
}