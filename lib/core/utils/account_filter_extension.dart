import 'package:flutter/material.dart';

extension FilterLabelExtension on String {
  /// Chuyển đổi nhãn chuỗi (Label) thành cặp [DateTimeRange] cụ thể
  DateTimeRange? toDateTimeRange(DateTimeRange? customRange) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (this) {
      case 'Today':
        return DateTimeRange(
            start: today,
            end: DateTime(now.year, now.month, now.day, 23, 59, 59));

      case 'This Month':
        final firstDay = DateTime(now.year, now.month, 1);
        final lastDay = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        return DateTimeRange(start: firstDay, end: lastDay);

      case 'Last Month':
        final firstDayLastMonth = DateTime(now.year, now.month - 1, 1);
        final lastDayLastMonth = DateTime(now.year, now.month, 0, 23, 59, 59);
        return DateTimeRange(start: firstDayLastMonth, end: lastDayLastMonth);

      case 'This Year':
        return DateTimeRange(
          start: DateTime(now.year, 1, 1),
          end: DateTime(now.year, 12, 31, 23, 59, 59),
        );

      case 'Custom Range...':
        if (customRange == null) return null;
        return DateTimeRange(
          start: DateTime(customRange.start.year, customRange.start.month,
              customRange.start.day),
          end: DateTime(customRange.end.year, customRange.end.month,
              customRange.end.day, 23, 59, 59),
        );

      case 'Last 30 Days':
      default:
        final thirtyDaysAgo = today.subtract(const Duration(days: 30));
        return DateTimeRange(
            start: thirtyDaysAgo,
            end: DateTime(now.year, now.month, now.day, 23, 59, 59));
    }
  }
}
