import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/utils/account_type_ext.dart';
import 'package:spend_io_app/core/utils/currency_formatter.dart';
import 'package:spend_io_app/features/wallet/domain/entities/account_entity.dart';

class AccountItemCard extends StatelessWidget {
  final AccountEntity account;
  final VoidCallback? onTap;

  const AccountItemCard({
    super.key,
    required this.account,
    this.onTap,
  });

  IconData _getIcon(AccountType type) {
    switch (type) {
      case AccountType.cash:
        return Icons.payments_rounded;
      case AccountType.bank:
        return Icons.account_balance_rounded;
      case AccountType.creditCard:
        return Icons.credit_card_rounded;
      case AccountType.eWallet:
        return Icons.account_balance_wallet_rounded;
      case AccountType.savingsAccount:
        return Icons.savings_rounded;
    }
  }

  Color _getBgColor(AccountType type, bool isDark) {
    if (isDark) {
      switch (type) {
        case AccountType.cash:
          return const Color(0x2681C784);
        case AccountType.bank:
          return const Color(0x2664B5F6);
        case AccountType.creditCard:
          return const Color(0x26FFB74D);
        case AccountType.eWallet:
          return const Color(0x26BA68C8);
        case AccountType.savingsAccount:
          return const Color(0x264DB6AC);
      }
    } else {
      switch (type) {
        case AccountType.cash:
          return const Color(0xFFE8F5E9);
        case AccountType.bank:
          return const Color(0xFFE3F2FD);
        case AccountType.creditCard:
          return const Color(0xFFFFF3E0);
        case AccountType.eWallet:
          return const Color(0xFFF3E5F5);
        case AccountType.savingsAccount:
          return const Color(0xFFE0F2F1);
      }
    }
  }

  Color _getIconColor(AccountType type, bool isDark) {
    if (isDark) {
      switch (type) {
        case AccountType.cash:
          return const Color(0xFF81C784);
        case AccountType.bank:
          return const Color(0xFF64B5F6);
        case AccountType.creditCard:
          return const Color(0xFFFFB74D);
        case AccountType.eWallet:
          return const Color(0xFFBA68C8);
        case AccountType.savingsAccount:
          return const Color(0xFF4DB6AC);
      }
    } else {
      switch (type) {
        case AccountType.cash:
          return const Color(0xFF2E7D32);
        case AccountType.bank:
          return const Color(0xFF1565C0);
        case AccountType.creditCard:
          return const Color(0xFFE65100);
        case AccountType.eWallet:
          return const Color(0xFF6A1B9A);
        case AccountType.savingsAccount:
          return const Color(0xFF00695C);
      }
    }
  }

  Color _getBalanceColor(double balance, bool isDark) {
    if (balance > 0) {
      return AppColors.success;
    } else if (balance < 0) {
      return AppColors.error;
    } else {
      return isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final cardBgColor = isDark ? AppColors.surfaceSecondaryDark : Colors.white;
    final primaryTextColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedTextColor = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;

    return Container(
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Left Section - Account Icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: _getBgColor(account.type, isDark),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Icon(
                      _getIcon(account.type),
                      color: _getIconColor(account.type, isDark),
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.md),
                // Middle Section - Account Information
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        account.type.displayName.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: mutedTextColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        account.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: primaryTextColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSizes.md),
                // Right Section - Balance & Action
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      CurrencyFormatter.format(account.balance),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _getBalanceColor(account.balance, isDark),
                      ),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: onTap,
                      child: const Text(
                        'Details >',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

