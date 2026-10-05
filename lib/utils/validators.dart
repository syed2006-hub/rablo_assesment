/// Comprehensive form input validation utilities for Day 10 Form Validation & Error Handling.
/// Validates required fields, formats, min/max values, special characters, age restrictions, and confirmation matches.
class Validators {
  Validators._();

  /// 1. Required field validation (checks null and empty strings)
  static String? validateRequired(String? value, [String fieldName = 'Field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// 2. Email validation using standard RFC 5322 regex
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required';
    }
    final trimmed = value.trim();
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$',
    );
    if (!emailRegex.hasMatch(trimmed)) {
      return 'Please enter a valid email address (e.g. user@domain.com)';
    }
    return null;
  }

  /// 3. Mobile phone number validation (10 digits, Indian mobile prefix 6, 7, 8, 9)
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    // Clean spaces, hyphens, and +91 prefix
    String cleaned = value.replaceAll(RegExp(r'[\s\-\+\(\)]'), '');
    if (cleaned.startsWith('91') && cleaned.length == 12) {
      cleaned = cleaned.substring(2);
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(cleaned)) {
      return 'Phone number must contain only numeric digits';
    }
    if (cleaned.length != 10) {
      return 'Phone number must be exactly 10 digits';
    }
    if (!RegExp(r'^[6-9]').hasMatch(cleaned)) {
      return 'Phone number must start with 6, 7, 8, or 9';
    }
    return null;
  }

  /// 4. Password validation with strength requirements
  static String? validatePassword(String? value, {int minLength = 6}) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }
    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    return null;
  }

  /// 5. Strong Password validation (length >= 8, letter, digit, optional special char)
  static String? validateStrongPassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (!RegExp(r'[A-Za-z]').hasMatch(value)) {
      return 'Password must contain at least one letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  /// 6. Confirmation match validation (Password, Account Number, etc.)
  static String? validateMatch(String? value, String? originalValue, [String fieldName = 'Passwords']) {
    if (value == null || value.trim().isEmpty) {
      return 'Please confirm your $fieldName';
    }
    if (value.trim() != originalValue?.trim()) {
      return '$fieldName do not match';
    }
    return null;
  }

  /// 7. Indian Financial System Code (IFSC) validation (RBI Standard: 4 letters, 0, 6 alphanumeric)
  static String? validateIfsc(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'IFSC code is required';
    }
    final cleaned = value.trim().toUpperCase();
    final ifscRegex = RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$');
    if (!ifscRegex.hasMatch(cleaned)) {
      return 'Invalid IFSC format (e.g. HDFC0001234)';
    }
    return null;
  }

  /// 8. Bank Account Number validation (numeric only, 9 to 18 digits)
  static String? validateAccountNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Account number is required';
    }
    final cleaned = value.trim();
    if (!RegExp(r'^[0-9]+$').hasMatch(cleaned)) {
      return 'Account number must contain only numbers';
    }
    if (cleaned.length < 9 || cleaned.length > 18) {
      return 'Account number must be between 9 and 18 digits';
    }
    return null;
  }

  /// 9. Postal PIN Code validation (exactly 6 numeric digits)
  static String? validatePinCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'PIN code is required';
    }
    final cleaned = value.trim();
    if (!RegExp(r'^[1-9][0-9]{5}$').hasMatch(cleaned)) {
      return 'Enter a valid 6-digit PIN code';
    }
    return null;
  }

  /// 10. Minimum and Maximum String Length validation
  static String? validateLength(
    String? value, {
    required int min,
    required int max,
    String fieldName = 'Input',
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    final length = value.trim().length;
    if (length < min) {
      return '$fieldName must be at least $min characters';
    }
    if (length > max) {
      return '$fieldName cannot exceed $max characters';
    }
    return null;
  }

  /// 11. Numeric range validation (Min / Max values for prices, sessions, etc.)
  static String? validateNumericRange(
    String? value, {
    double? min,
    double? max,
    String fieldName = 'Amount',
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    final parsed = double.tryParse(value.replaceAll(',', '').trim());
    if (parsed == null) {
      return '$fieldName must be a valid number';
    }
    if (min != null && parsed < min) {
      return '$fieldName must be at least $min';
    }
    if (max != null && parsed > max) {
      return '$fieldName cannot exceed $max';
    }
    return null;
  }

  /// 12. Special characters prevention (allows letters, numbers, spaces, and hyphens)
  static String? validateNoSpecialChars(String? value, [String fieldName = 'Field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    if (!RegExp(r'^[a-zA-Z0-9\s\-]+$').hasMatch(value.trim())) {
      return '$fieldName cannot contain special characters';
    }
    return null;
  }

  /// 13. Strictly validates 18+ age requirement
  static String? validateAge18Plus(DateTime? dateOfBirth) {
    if (dateOfBirth == null) {
      return 'Date of birth is required';
    }
    final today = DateTime.now();
    int age = today.year - dateOfBirth.year;
    if (today.month < dateOfBirth.month ||
        (today.month == dateOfBirth.month && today.day < dateOfBirth.day)) {
      age--;
    }
    if (age < 18) {
      return 'User must be at least 18 years old (Current age: $age)';
    }
    return null;
  }
}
