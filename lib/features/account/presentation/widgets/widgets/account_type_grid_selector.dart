import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_radius.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/utils/account_type_ext.dart';
import 'package:spend_io_app/features/account/domain/entities/account_entity.dart';

class AccountTypeGridSelector extends StatelessWidget {
  final AccountType selectedType;
  final ValueChanged<AccountType> onTypeSelected;

  const AccountTypeGridSelector({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
  });

  IconData _getDefaultIcon(AccountType type) {
    switch (type) {
      case AccountType.cash:
        return Icons.wallet;
      case AccountType.bank:
        return Icons.account_balance;
      case AccountType.eWallet:
        return Icons.account_balance_wallet;
      case AccountType.creditCard:
        return Icons.credit_card;
      case AccountType.savingsAccount:
        return Icons.savings;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedTextColor = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final itemBgColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSizes.sm,
        mainAxisSpacing: AppSizes.sm,
        childAspectRatio: 2.2,
      ),
      itemCount: AccountType.values.length,
      itemBuilder: (context, index) {
        final type = AccountType.values[index];
        final isSelected = selectedType == type;
        final Color typeColor = type.mainColor;
        final Color bgColor = isDark ? typeColor.withValues(alpha: 0.2) : type.bgColor;

        return GestureDetector(
          onTap: () => onTypeSelected(type),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
            decoration: BoxDecoration(
              color: isSelected ? bgColor : itemBgColor,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: isSelected ? typeColor : borderColor,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getDefaultIcon(type),
                  color: isSelected ? typeColor : mutedTextColor,
                  size: 24,
                ),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Text(
                    type.displayName,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? primaryTextColor
                          : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
