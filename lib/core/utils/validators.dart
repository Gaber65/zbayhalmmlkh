import 'package:flutter/services.dart';

/// Form Validators
/// Provides validation functions for common form fields
class Validators {
  // Private constructor to prevent instantiation
  Validators._();

  /// Validates if field is not empty
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  /// Validates email format
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Validates password strength
  static String? password(String? value, {int minLength = 8}) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }

    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }

    return null;
  }

  /// Validates if passwords match
  static String? confirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  /// Validates phone number
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');

    if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'[\s-]'), ''))) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  /// Validates minimum length
  static String? minLength(String? value, int length, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }

    if (value.length < length) {
      return '${fieldName ?? 'This field'} must be at least $length characters';
    }

    return null;
  }

  /// Validates maximum length
  static String? maxLength(String? value, int length, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (value.length > length) {
      return '${fieldName ?? 'This field'} must not exceed $length characters';
    }

    return null;
  }

  /// Validates numeric input
  static String? numeric(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }

    if (double.tryParse(value) == null) {
      return '${fieldName ?? 'This field'} must be a number';
    }

    return null;
  }

  /// Validates URL format
  static String? url(String? value) {
    if (value == null || value.isEmpty) {
      return 'URL is required';
    }

    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );

    if (!urlRegex.hasMatch(value)) {
      return 'Please enter a valid URL';
    }

    return null;
  }

  /// Validates credit card number
  static String? creditCard(String? value) {
    if (value == null || value.isEmpty) {
      return 'Credit card number is required';
    }

    final cardNumber = value.replaceAll(RegExp(r'[\s-]'), '');

    if (cardNumber.length < 13 || cardNumber.length > 19) {
      return 'Please enter a valid credit card number';
    }

    // Luhn algorithm
    int sum = 0;
    bool alternate = false;

    for (int i = cardNumber.length - 1; i >= 0; i--) {
      int digit = int.parse(cardNumber[i]);

      if (alternate) {
        digit *= 2;
        if (digit > 9) {
          digit = (digit % 10) + 1;
        }
      }

      sum += digit;
      alternate = !alternate;
    }

    if (sum % 10 != 0) {
      return 'Please enter a valid credit card number';
    }

    return null;
  }

  /// Validates date format (dd/MM/yyyy)
  static String? date(String? value) {
    if (value == null || value.isEmpty) {
      return 'Date is required';
    }

    final dateRegex = RegExp(r'^\d{2}/\d{2}/\d{4}$');

    if (!dateRegex.hasMatch(value)) {
      return 'Please enter date in format dd/MM/yyyy';
    }

    final parts = value.split('/');
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);

    if (day == null || month == null || year == null) {
      return 'Invalid date';
    }

    if (month < 1 || month > 12) {
      return 'Invalid month';
    }

    if (day < 1 || day > 31) {
      return 'Invalid day';
    }

    return null;
  }

  /// Combines multiple validators
  static String? Function(String?) combine(
    List<String? Function(String?)> validators,
  ) {
    return (String? value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) {
          return result;
        }
      }
      return null;
    };
  }

  /// Normalizes Arabic & Persian digits to Western digits (0-9)
  static String normalizeDigits(String input) {
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    const persian = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    String result = input;
    for (int i = 0; i < 10; i++) {
      result = result.replaceAll(arabic[i], '$i');
      result = result.replaceAll(persian[i], '$i');
    }
    return result;
  }

  /// Normalizes any Saudi mobile number format to +9665XXXXXXXX
  /// Accepts: 05XXXXXXXX, 5XXXXXXXX, +9665XXXXXXXX, 009665XXXXXXXX, 9665XXXXXXXX
  static String? normalizeSaudiPhone(String? phone) {
    if (phone == null || phone.trim().isEmpty) return null;
    String cleaned = normalizeDigits(phone).replaceAll(RegExp(r'[\s\-\(\)\.]+'), '');
    if (cleaned.startsWith('00966')) {
      cleaned = '+${cleaned.substring(2)}';
    } else if (cleaned.startsWith('966')) {
      cleaned = '+$cleaned';
    } else if (cleaned.startsWith('05') && cleaned.length == 10) {
      cleaned = '+966${cleaned.substring(1)}';
    } else if (cleaned.startsWith('5') && cleaned.length == 9) {
      cleaned = '+966$cleaned';
    } else if (!cleaned.startsWith('+')) {
      cleaned = '+$cleaned';
    }
    return cleaned;
  }

  /// Strictly validates Saudi mobile phone format (+9665XXXXXXXX)
  static bool isValidSaudiPhone(String? phone) {
    final normalized = normalizeSaudiPhone(phone);
    if (normalized == null) return false;
    return RegExp(r'^\+9665\d{8}$').hasMatch(normalized);
  }
}

/// Input Formatter for Saudi Mobile Numbers
/// - Converts Eastern Arabic & Persian digits (٠-٩) to English (0-9)
/// - Strips any pasted country codes (+966, 00966, 966)
/// - Enforces maximum length: 10 digits for numbers starting with 0 (05XXXXXXXX)
///   or 9 digits for numbers starting with 5 (5XXXXXXXX)
class SaudiPhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // 1. Normalize Eastern Arabic & Persian digits
    String normalized = Validators.normalizeDigits(newValue.text);

    // 2. Strip non-digits and non-plus
    String cleaned = normalized.replaceAll(RegExp(r'[^\d+]'), '');

    // 3. Handle pasted international prefixes
    if (cleaned.startsWith('+966')) {
      cleaned = cleaned.substring(4);
    } else if (cleaned.startsWith('00966')) {
      cleaned = cleaned.substring(5);
    } else if (cleaned.startsWith('966')) {
      cleaned = cleaned.substring(3);
    }

    // Strip any remaining non-digits
    cleaned = cleaned.replaceAll(RegExp(r'\D'), '');

    // 4. Enforce strict max length (05XXXXXXXX -> 10, 5XXXXXXXX -> 9)
    final int maxLength = cleaned.startsWith('0') ? 10 : 9;
    if (cleaned.length > maxLength) {
      cleaned = cleaned.substring(0, maxLength);
    }

    return TextEditingValue(
      text: cleaned,
      selection: TextSelection.collapsed(offset: cleaned.length),
    );
  }
}
