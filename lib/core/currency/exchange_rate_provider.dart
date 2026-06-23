
import 'app_currencies.dart';
import 'exchange_rate.dart';

abstract class ExchangeRateProvider {
  ExchangeRate getRate(String from, String to);
}

class LocalExchangeRateProvider implements ExchangeRateProvider {
  const LocalExchangeRateProvider();

  static const String baseCurrency = AppCurrencies.usdCode;

  static const Map<String, double> rates = {
    AppCurrencies.usdCode: 1.0,
    AppCurrencies.vndCode: 26000.0,
  };

  @override
  ExchangeRate getRate(String from, String to) {
    final String cleanFrom = from.toUpperCase();
    final String cleanTo = to.toUpperCase();

    final double rateFrom = rates[cleanFrom] ?? 1.0;
    final double rateTo = rates[cleanTo] ?? 1.0;

    final double conversionRate = rateTo / rateFrom;

    return ExchangeRate(
      from: cleanFrom,
      to: cleanTo,
      rate: conversionRate,
      updatedAt: DateTime.now(),
    );
  }
}
