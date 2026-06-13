/// Formats fractional percentage values (e.g. 0.12 -> '12%')
String formatPercentage(double value) {
  return '${(value * 100).toStringAsFixed(0)}%';
}
