import 'package:flutter/material.dart';

class InsightSpendingItem {
  final String name;
  final double amount;
  final double percentage;
  final Color color;
  final int iconCodePoint;
  final String? iconFontFamily;

  InsightSpendingItem({
    required this.name,
    required this.amount,
    required this.percentage,
    required this.color,
    required this.iconCodePoint,
    this.iconFontFamily,
  });
}
