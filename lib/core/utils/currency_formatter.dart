import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '',
    decimalDigits: 0,
  );

  /// Định dạng đầy đủ
  static String format(
    double amount, {
    String locale = 'vi_VN', //Gán mặc định tạm thời
    String currencyCode = 'VND', //Gán mặc định tạm thời
    int? decimalDigits,
  }) {
    if (locale == 'vi_VN' && currencyCode == 'VND') {
      return '${_currencyFormat.format(amount).replaceAll('\u00A0', '').trim()}đ';
    }

    // Luồng chuẩn quốc tế xử lý động (Sẽ dùng sau)
    final formatter = NumberFormat.currency(
      locale: locale,
      name: currencyCode,
      decimalDigits: decimalDigits,
    );
    return formatter.format(amount).replaceAll('\u00A0', ' ').trim();
  }

  /// Định dạng viết tắt
  static String compact(
    double amount, {
    String locale = 'vi_VN', // Gán mặc định tạm thời
    String currencyCode = 'VND', // Gán mặc định tạm thời
  }) {
    if (locale == 'vi_VN' && currencyCode == 'VND') {
      if (amount >= 1000) {
        return _currencyFormat.format(amount).replaceAll('\u00A0', '').trim();
      }
      return amount.toStringAsFixed(0);
    }

    // Luồng chuẩn quốc tế xử lý động (Sẽ dùng sau)
    final symbol =
        NumberFormat.simpleCurrency(locale: locale, name: currencyCode)
            .currencySymbol;
    final formatter = NumberFormat.compactCurrency(
      locale: locale,
      symbol: symbol,
    );
    return formatter.format(amount).replaceAll('\u00A0', ' ').trim();
  }
}

/// Global formatting helper for fully formatted currency
String formatCurrency(
  double amount, {
  String locale = 'vi_VN',
  String currencyCode = 'VND',
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
  String locale = 'vi_VN',
  String currencyCode = 'VND',
}) {
  return CurrencyFormatter.compact(
    amount,
    locale: locale,
    currencyCode: currencyCode,
  );
}
