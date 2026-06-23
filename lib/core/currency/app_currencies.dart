
import 'currency_entity.dart';

class AppCurrencies {
  AppCurrencies._();

  static const String usdCode = 'USD';
  static const String vndCode = 'VND';

  static const usd = CurrencyEntity(
    code: usdCode,
    symbol: '\$',
    name: 'US Dollar',
  );

  static const vnd = CurrencyEntity(
    code: vndCode,
    symbol: 'đ',
    name: 'Vietnamese Dong',
  );

  static const all = [usd, vnd];

  static bool isValid(String code) {
    return all.any((c) => c.code.toUpperCase() == code.toUpperCase());
  }

  static CurrencyEntity fromCode(String code) {
    return all.firstWhere(
      (c) => c.code.toUpperCase() == code.toUpperCase(),
      orElse: () => usd,
    );
  }
}
