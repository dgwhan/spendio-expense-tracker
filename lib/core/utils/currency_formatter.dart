import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static String currentCurrency = 'VND';
  static String currentLocale = 'vi_VN';

  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '',
    decimalDigits: 0,
  );

  /// Định dạng đầy đủ
  static String format(
    double amount, {
    String? locale,
    String? currencyCode,
    int? decimalDigits,
  }) {
    final activeLocale = locale ?? currentLocale;
    final activeCurrency = currencyCode ?? currentCurrency;

    if (activeLocale == 'vi_VN' && activeCurrency == 'VND') {
      return '${_currencyFormat.format(amount).replaceAll('\u00A0', '').trim()}đ';
    }

    final formatter = NumberFormat.currency(
      locale: activeLocale,
      name: activeCurrency,
      decimalDigits: decimalDigits ?? 2,
    );
    return formatter.format(amount).replaceAll('\u00A0', ' ').trim();
  }

  /// Định dạng viết tắt
  static String compact(
    double amount, {
    String? locale,
    String? currencyCode,
  }) {
    final activeLocale = locale ?? currentLocale;
    final activeCurrency = currencyCode ?? currentCurrency;

    if (activeLocale == 'vi_VN' && activeCurrency == 'VND') {
      if (amount >= 1000) {
        return _currencyFormat.format(amount).replaceAll('\u00A0', '').trim();
      }
      return amount.toStringAsFixed(0);
    }

    final symbol =
        NumberFormat.simpleCurrency(locale: activeLocale, name: activeCurrency)
            .currencySymbol;
    final formatter = NumberFormat.compactCurrency(
      locale: activeLocale,
      symbol: symbol,
    );
    return formatter.format(amount).replaceAll('\u00A0', ' ').trim();
  }
}

/// Global formatting helper for fully formatted currency
String formatCurrency(
  double amount, {
  String? locale,
  String? currencyCode,
  int? decimalDigits,
}) {
  return CurrencyFormatter.format(
    amount,
    locale: locale,
    currencyCode: currencyCode,
    decimalDigits: decimalDigits,
  );
}

/// Global formatting helper for compact currency
String formatCompactCurrency(
  double amount, {
  String? locale,
  String? currencyCode,
}) {
  return CurrencyFormatter.compact(
    amount,
    locale: locale,
    currencyCode: currencyCode,
  );
}

