import 'package:flutter/material.dart';
import 'package:spend_io_app/features/transaction/data/models/transaction_model.dart';

/// [App Location] Presentation layer utility mapping data models to UI representations.
/// [Core Function] Generates Flutter-specific Material UI properties (Colors, Icons) safely from database primitive types.
extension TransactionUiMapper on TransactionModel {
  /// Dynamically parses the stored string hex back into a Flutter Color object
  Color? get categoryColor {
    if (categoryColorHex == null) return null;
    final hexColor = categoryColorHex!.replaceAll('#', '');
    return Color(int.parse('FF$hexColor', radix: 16));
  }

  /// Dynamically computes a translucent background style based on the parsed color
  Color? get categoryBgColor => categoryColor?.withValues(alpha: 0.15);

  /// Converts the string code back into standard Material Icons
  IconData get categoryIcon {
    if (categoryIconCode == null) return Icons.receipt_long_rounded;
    // Map string codes or integer codePoints to actual IconData here
    return Icons.receipt_long_rounded;
  }
}
