
import 'app_currencies.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  /// Format dynamic amount with dots as thousands separator, whole numbers only,
  /// and placing the currency symbol after the amount with a space.
  static String format(
    double amount, {
    String? locale,
    required String currencyCode,
    int? decimalDigits,
  }) {
    final currencyEntity = AppCurrencies.fromCode(currencyCode);
    final symbol = currencyEntity.symbol;

    final bool isNegative = amount < 0;
    final int roundedAmount = amount.abs().round();
    final String str = roundedAmount.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
      count++;
    }
    final String formatted = buffer.toString().split('').reversed.join('');
    final String sign = isNegative ? '-' : '';

    return '$sign$formatted $symbol';
  }

  /// Parse text representation of money back to double
  static double? parse(String text, {required String currencyCode}) {
    final String cleanText = text
        .replaceAll('đ', '')
        .replaceAll('\$', '')
        .replaceAll('VND', '')
        .replaceAll('USD', '')
        .replaceAll('.', '')
        .replaceAll(',', '')
        .replaceAll(' ', '')
        .trim();

    return double.tryParse(cleanText);
  }
}

/// Global formatting helper for fully formatted currency
String formatCurrency(
  double amount, {
  String? locale,
  required String currencyCode,
  int? decimalDigits,
}) {
  return CurrencyFormatter.format(
    amount,
    locale: locale,
    currencyCode: currencyCode,
    decimalDigits: decimalDigits,
  );
}
