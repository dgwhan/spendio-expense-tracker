import 'package:intl/intl.dart';

class DateFormatter {
  static String toMonthYearString(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }
}
