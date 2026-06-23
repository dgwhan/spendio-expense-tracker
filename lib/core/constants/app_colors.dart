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
  static const Color error = Color(0xFFEF4444); // Màu đỏ cho chữ và nền nhạt
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF06B6D4);

  //finance
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

  // Account type specific colors (Light/Dark Mode and Backgrounds)
  static const Color cashLight = Color(0xFF2E7D32);
  static const Color cashDark = Color(0xFF81C784);
  static const Color cashBgLight = Color(0xFFE8F5E9);
  static const Color cashBgDark = Color(0x2681C784);

  static const Color bankLight = Color(0xFF1565C0);
  static const Color bankDark = Color(0xFF64B5F6);
  static const Color bankBgLight = Color(0xFFE3F2FD);
  static const Color bankBgDark = Color(0x2664B5F6);

  static const Color creditCardLight = Color(0xFFE65100);
  static const Color creditCardDark = Color(0xFFFFB74D);
  static const Color creditCardBgLight = Color(0xFFFFF3E0);
  static const Color creditCardBgDark = Color(0x26FFB74D);

  static const Color eWalletLight = Color(0xFF6A1B9A);
  static const Color eWalletDark = Color(0xFFBA68C8);
  static const Color eWalletBgLight = Color(0xFFF3E5F5);
  static const Color eWalletBgDark = Color(0x26BA68C8);

  static const Color savingsAccountLight = Color(0xFF00695C);
  static const Color savingsAccountDark = Color(0xFF4DB6AC);
  static const Color savingsAccountBgLight = Color(0xFFE0F2F1);
  static const Color savingsAccountBgDark = Color(0x264DB6AC);

  // outline
  static const Color outline = Color(0xFFE5E7EB);
  static const Color outlineDark = Color(0xFF334155);

  // natural shadows
  static const Color shadowNatural1 = Color(0x0A000000);
  static const Color shadowNatural2 = Color(0x05000000);
  static const Color shadowNaturalDark1 = Color(0x1A000000);
  static const Color shadowNaturalDark2 = Color(0x0D000000);

  // basic colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Color(0x00000000);

  // category colors
  static const Color categoryFoodDrinkLight = Color(0xFFEF6C00);
  static const Color categoryFoodDrinkDark = Color(0xFFE65100);
  static const Color categoryFoodDrinkBgLight = Color(0xFFFFF3E0);
  static const Color categoryFoodDrinkBgDark = Color(0x4DE65100);

  static const Color categoryTransportLight = Color(0xFF2E7D32);
  static const Color categoryTransportDark = Color(0xFF1B5E20);
  static const Color categoryTransportBgLight = Color(0xFFE8F5E9);
  static const Color categoryTransportBgDark = Color(0x4D1B5E20);

  static const Color categoryGroceriesLight = Color(0xFF1565C0);
  static const Color categoryGroceriesDark = Color(0xFF0D47A1);
  static const Color categoryGroceriesBgLight = Color(0xFFE3F2FD);
  static const Color categoryGroceriesBgDark = Color(0x4D0D47A1);

  static const Color categoryBillsLight = Color(0xFFC62828);
  static const Color categoryBillsDark = Color(0xFFB71C1C);
  static const Color categoryBillsBgLight = Color(0xFFFFEBEE);
  static const Color categoryBillsBgDark = Color(0x4DB71C1C);

  static const Color categoryShoppingLight = Color(0xFF6A1B9A);
  static const Color categoryShoppingDark = Color(0xFF4A148C);
  static const Color categoryShoppingBgLight = Color(0xFFF3E5F5);
  static const Color categoryShoppingBgDark = Color(0x4D4A148C);

  static const Color categorySalaryLight = Color(0xFF00695C);
  static const Color categorySalaryDark = Color(0xFF004D40);
  static const Color categorySalaryBgLight = Color(0xFFE0F2F1);
  static const Color categorySalaryBgDark = Color(0x4D004D40);

  static const Color categoryOtherLight = Color(0xFF424242);
  static const Color categoryOtherDark = Color(0xFF212121);
  static const Color categoryOtherBgLight = Color(0xFFF5F5F5);
  static const Color categoryOtherBgDark = Color(0x4D212121);
}
