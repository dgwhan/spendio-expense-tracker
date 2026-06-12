import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // brand
  static const Color primary = Color(0xFF5B5FEF);
  static const Color primaryHover = Color(0xFF4C50E0);
  static const Color primaryActive = Color(0xFF3F43D3);

  // gradients
  static const Color gradientStart = Color(0xFF5B5FEF);
  static const Color gradientEnd = Color(0xFF8B5CF6);

  // neutral - light
  static const Color backgroundLight = Color(0xFFF7F8FC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceSecondaryLight = Color(0xFFF1F3F9);

  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color dividerLight = Color(0xFFECEEF5);

  static const Color textPrimaryLight = Color(0xFF111827);
  static const Color textSecondaryLight = Color(0xFF4B5563);
  static const Color textMutedLight = Color(0xFF9CA3AF);

  // neutral - dark
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF111827);
  static const Color surfaceSecondaryDark = Color(0xFF1E293B);

  static const Color borderDark = Color(0xFF334155);
  static const Color dividerDark = Color(0xFF1E293B);

  static const Color textPrimaryDark = Color(0xFFF9FAFB);
  static const Color textSecondaryDark = Color(0xFFCBD5E1);
  static const Color textMutedDark = Color(0xFF94A3B8);

  // semantic
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF06B6D4);

  // finance
  static const Color income = success;
  static const Color expense = error;
  static const Color savings = info;
  static const Color investment = Color(0xFF8B5CF6);

  // states
  static const Color disabled = Color(0xFFD1D5DB);
  static const Color overlay = Color(0x66000000);

  // shadow
  static const Color shadow = Color(0x14000000);

  //account card colors
  static const Color creditCardAccount = Color(0xFFE57373);
  static const Color cashAccount = Color(0xFF81C784);
  static const Color eWalletAccount = Color(0xFF64B5F6);
  static const Color defaultAccount = Color(0xFFFFB74D);
  static const Color surfaceCardLight = Color(0xFFF9FAFB);
}
