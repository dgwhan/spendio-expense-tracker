import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  final String currencyCode;

  CurrencyInputFormatter({this.currencyCode = 'USD'});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (newText.isEmpty) return newValue.copyWith(text: '');

    final double amount = double.parse(newText);
    if (amount > 999999999) return oldValue;

    final formatter = NumberFormat.decimalPattern('vi_VN');

    final formatted = formatter.format(amount);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
