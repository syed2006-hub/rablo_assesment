/// Reusable form input validation utilities.
class Validators {
  Validators._();

  /// Validates email address format.
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validates password field presence and minimum length.
  static String? validatePassword(String? value, {int minLength = 6}) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }
    if (value.trim().length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    return null;
  }

  /// Validates that a required input is not left empty.
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
}
