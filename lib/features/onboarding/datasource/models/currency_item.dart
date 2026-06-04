class CurrencyItem {
  final String countryName;
  final String code;
  final String flag;

  const CurrencyItem({
    required this.countryName,
    required this.code,
    required this.flag,
  });
}

const List<CurrencyItem> supportedCurrencies = [
  CurrencyItem(countryName: 'Vietnamese', code: 'VND', flag: '🇻🇳'),
  CurrencyItem(countryName: 'United States', code: 'USD', flag: '🇺🇸'),
  CurrencyItem(countryName: 'Europe', code: 'EUR', flag: '🇪🇺'),
  CurrencyItem(countryName: 'Japan', code: 'JPY', flag: '🇯🇵'),
];
