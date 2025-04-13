import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Utility helpers for formatting, validation, and UI elements
class Helpers {
  /// Generates a simple UUID
  static String generateUuid() {
    final now = DateTime.now();
    final randomComponent = now.microsecondsSinceEpoch.toString();
    return 'id-${now.millisecondsSinceEpoch}-$randomComponent';
  }
  
  /// Validates license plate format
  static bool isValidLicensePlate(String plate) {
    // Basic validation - can be customized for specific formats
    return plate.length >= 2 && plate.length <= 10;
  }
  /// Truncate a string to a specific length and add an ellipsis
  static String truncateString(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    }
    return '${text.substring(0, maxLength)}...';
  }
  
  /// Capitalize the first letter of a string
  static String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return '';
    return '${text[0].toUpperCase()}${text.substring(1)}';
  }
  
  /// Format status for display
  static String getPrettyStatus(String status) {
    // Convert snake_case or kebab-case to Title Case
    final words = status.replaceAll('_', ' ').replaceAll('-', ' ').split(' ');
    return words.map((word) => capitalizeFirstLetter(word)).join(' ');
  }
  /// Format a double as currency
  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  /// Format a date as a readable string
  static String formatDate(DateTime date, {String format = 'MMM dd, yyyy'}) {
    return DateFormat(format).format(date);
  }

  /// Format a date with time
  static String formatDateTime(DateTime date) {
    return DateFormat('MMM dd, yyyy - hh:mm a').format(date);
  }

  /// Get appropriate color for status
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'approved':
      case 'completed':
      case 'success':
        return Colors.green;
      case 'pending':
      case 'processing':
      case 'in_progress':
        return Colors.blue;
      case 'overdue':
      case 'rejected':
      case 'cancelled':
      case 'failed':
        return Colors.red;
      case 'partial':
      case 'warning':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  /// Format phone number for display
  static String formatPhoneNumber(String phone) {
    if (phone.length == 10) {
      return '(${phone.substring(0, 3)}) ${phone.substring(3, 6)}-${phone.substring(6)}';
    }
    return phone;
  }

  /// Convert hex color string to Color
  static Color hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Calculate time difference in a readable format (e.g., "2 days ago")
  static String timeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} year(s) ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month(s) ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day(s) ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour(s) ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute(s) ago';
    } else {
      return 'Just now';
    }
  }

  /// Generate a random color
  static Color getRandomColor() {
    return Color.fromARGB(
      255,
      (DateTime.now().millisecondsSinceEpoch % 255).toInt(),
      (DateTime.now().millisecondsSinceEpoch % 200).toInt(),
      (DateTime.now().microsecondsSinceEpoch % 255).toInt(),
    );
  }

  /// Get the first letter of each word in a string (for avatars)
  static String getInitials(String fullName) {
    List<String> names = fullName.split(' ');
    String initials = '';
    
    if (names.length > 0) {
      if (names[0].isNotEmpty) {
        initials += names[0][0];
      }
      if (names.length > 1 && names[1].isNotEmpty) {
        initials += names[1][0];
      }
    }
    
    return initials.toUpperCase();
  }

  /// Check if a date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  /// Check if a date is tomorrow
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year && date.month == tomorrow.month && date.day == tomorrow.day;
  }
}