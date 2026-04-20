import '../constants/app_constants.dart';

/// ---------------------------------------------------------------------------
/// Centralized validators used in both UI (form validation) and domain layer.
/// Returns a String error message on failure, or null on success.
/// ---------------------------------------------------------------------------
class AppValidators {
  AppValidators._();

  // ── Student ID ─────────────────────────────────────────────────────────────

  /// Validates a student ID string against the university rules:
  ///  - Must not be empty
  ///  - Must contain exactly [AppConstants.studentIdLength] digits
  ///  - Must contain only numeric characters
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

    return null; // valid
  }

  /// Returns true if the student ID passes all rules without an error message.
  static bool isValidStudentId(String value) =>
      validateStudentId(value) == null;

  // ── Generic ────────────────────────────────────────────────────────────────

  /// Validates that a field is not empty.
  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required.';
    }
    return null;
  }

  /// Validates that the string is a valid email address.
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required.';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) return 'Enter a valid email address.';
    return null;
  }

  /// Validates that a value is within a given character range.
  static String? validateLength(
    String? value, {
    required int min,
    required int max,
    String? fieldName,
  }) {
    if (value == null) return '${fieldName ?? 'Field'} is required.';
    if (value.length < min) {
      return '${fieldName ?? 'Field'} must be at least $min characters.';
    }
    if (value.length > max) {
      return '${fieldName ?? 'Field'} must be at most $max characters.';
    }
    return null;
  }

  // ── Private Helpers ────────────────────────────────────────────────────────

  static bool _isNumericOnly(String value) =>
      RegExp(AppConstants.studentIdPattern).hasMatch(value);
}