import 'package:intl/intl.dart';

class DateFormatter {
  static String toMonthYearString(DateTime date) {
    return monthYear(date);
  }
}

/// Formats date to 'MMMM yyyy' (e.g. 'June 2026')
String monthYear(DateTime date) {
  return DateFormat('MMMM yyyy').format(date);
}

/// Formats date to 'MMM d, yyyy' (e.g. 'Jun 14, 2026')
String shortDate(DateTime date) {
  return DateFormat('MMM d, yyyy').format(date);
}

/// Formats date to relative time text (e.g. 'Today, 14:30', 'Yesterday, 09:15', or 'MMMM d, yyyy')
String relativeDate(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = DateTime(now.year, now.month, now.day - 1);
  final targetDate = DateTime(date.year, date.month, date.day);

  if (targetDate == today) {
    return 'Today, ${DateFormat('HH:mm').format(date)}';
  } else if (targetDate == yesterday) {
    return 'Yesterday, ${DateFormat('HH:mm').format(date)}';
  } else {
    return DateFormat('MMMM d, yyyy').format(date);
  }
}
