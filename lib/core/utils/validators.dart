/// Utility class for form field validation
class Validators {
  /// Validates email address format
  static bool isValidEmail(String email) {
    final pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    final regExp = RegExp(pattern);
    return regExp.hasMatch(email);
  }

  /// Validates password strength
  static bool isValidPassword(String password) {
    // Password must be at least 8 characters
    return password.length >= 8;
  }

  /// Validates amount format (numeric value with optional decimal point)
  static bool isValidAmount(String amount) {
    try {
      final value = double.tryParse(amount);
      return value != null && value > 0;
    } catch (e) {
      return false;
    }
  }

  /// Validates phone number
  static bool isValidPhone(String phone) {
    // Basic phone validation - can be expanded for country-specific formats
    final pattern = r'^[0-9]{10}$';
    final regExp = RegExp(pattern);
    return regExp.hasMatch(phone);
  }

  /// Validates a credit card number using Luhn algorithm
  static bool isValidCreditCard(String cardNumber) {
    // Remove any spaces or dashes
    final String cleanNumber = cardNumber.replaceAll(RegExp(r'[\s-]'), '');
    
    // Check if the number contains only digits
    if (!RegExp(r'^[0-9]+$').hasMatch(cleanNumber)) {
      return false;
    }
    
    // Luhn algorithm
    int sum = 0;
    bool alternate = false;
    for (int i = cleanNumber.length - 1; i >= 0; i--) {
      int n = int.parse(cleanNumber.substring(i, i + 1));
      if (alternate) {
        n *= 2;
        if (n > 9) {
          n = (n % 10) + 1;
        }
      }
      sum += n;
      alternate = !alternate;
    }
    
    return (sum % 10 == 0);
  }

  /// Validates a name (non-empty and contains only letters and spaces)
  static bool isValidName(String name) {
    if (name.isEmpty) return false;
    final pattern = r'^[a-zA-Z\s]+$';
    final regExp = RegExp(pattern);
    return regExp.hasMatch(name);
  }

  /// Validates if a date is in the future
  static bool isFutureDate(DateTime date) {
    final now = DateTime.now();
    return date.isAfter(now);
  }

  /// Validates if text has minimum length
  static bool hasMinLength(String text, int length) {
    return text.length >= length;
  }

  /// Validates if text has maximum length
  static bool hasMaxLength(String text, int length) {
    return text.length <= length;
  }

  /// Validates license plate format
  static bool isValidLicensePlate(String plate) {
    // Basic validation - can be customized for specific formats
    if (plate.length < 2 || plate.length > 10) {
      return false;
    }
    
    // Allow letters, numbers, and limited special characters
    final pattern = r'^[A-Za-z0-9\-\s]+$';
    final regExp = RegExp(pattern);
    return regExp.hasMatch(plate);
  }
}