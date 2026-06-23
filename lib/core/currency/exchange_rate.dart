class ExchangeRate {
  final String from;
  final String to;
  final double rate;
  final DateTime updatedAt;

  const ExchangeRate({
    required this.from,
    required this.to,
    required this.rate,
    required this.updatedAt,
  });
}
