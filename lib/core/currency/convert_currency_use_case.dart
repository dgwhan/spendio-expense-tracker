
import 'exchange_rate_provider.dart';

class ConvertCurrencyUseCase {
  final ExchangeRateProvider provider;

  const ConvertCurrencyUseCase(this.provider);

  double execute({
    required double amount,
    required String from,
    required String to,
  }) {
    if (from.toUpperCase() == to.toUpperCase()) {
      return amount;
    }
    final rateObj = provider.getRate(from, to);
    return amount * rateObj.rate;
  }
}
