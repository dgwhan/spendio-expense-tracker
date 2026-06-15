import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/features/account/domain/entities/account_entity.dart';

extension AccountTypeExt on AccountType {
  Color get mainColor {
    switch (this) {
      case AccountType.creditCard:
        return AppColors.creditCardAccount;
      case AccountType.cash:
        return AppColors.cashAccount;
      case AccountType.eWallet:
        return AppColors.eWalletAccount;
      default:
        return AppColors.defaultAccount;
    }
  }

  Color get bgColor => mainColor.withValues(alpha: 0.1);

  String get displayName {
    switch (this) {
      case AccountType.cash:
        return 'Cash';
      case AccountType.bank:
        return 'Bank';
      case AccountType.creditCard:
        return 'Credit Card';
      case AccountType.eWallet:
        return 'E-Wallet';
      default:
        return 'Other';
    }
  }
}
