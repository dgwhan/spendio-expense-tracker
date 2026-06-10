import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_radius.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/features/wallet/domain/entities/account_entity.dart';
import 'package:spend_io_app/features/wallet/presentation/widgets/accounts/widgets/account_icon_container.dart';
import 'package:spend_io_app/features/wallet/presentation/widgets/accounts/widgets/account_type_chip.dart';

class AccountItemCard extends StatelessWidget {
  final AccountEntity account;
  final VoidCallback onTap;

  const AccountItemCard({
    super.key,
    required this.account,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isNegative = account.balance < 0;
    final currencyFormatter =
        NumberFormat.currency(locale: 'en_US', symbol: '\$');

    // Cấu hình màu sắc theo loại tài khoản
    Color mainColor = AppColors.primary;
    Color bgColor = AppColors.primary.withValues(alpha: 0.1);

    if (account.type == AccountType.creditCard) {
      mainColor = AppColors.expense;
      bgColor = AppColors.expense.withValues(alpha: 0.1);
    } else if (account.type == AccountType.cash) {
      mainColor = AppColors.income;
      bgColor = AppColors.income.withValues(alpha: 0.1);
    } else if (account.type == AccountType.eWallet) {
      mainColor = AppColors.investment; // Màu tím mộng mơ cho Ví điện tử
      bgColor = AppColors.investment.withValues(alpha: 0.1);
    } else {
      mainColor = AppColors.info; // Màu xanh cyan cho Bank ngân hàng
      bgColor = AppColors.info.withValues(alpha: 0.1);
    }

    return Card(
      elevation: 0,
      color: AppColors.surfaceLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: const BorderSide(color: AppColors.borderLight, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AccountIconContainer(
                    icon: account.icon,
                    iconColor: mainColor,
                    backgroundColor: bgColor,
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.textMutedLight,
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: AppSizes.xs),
                  AccountTypeChip(label: _getAccountTypeName(account.type)),
                ],
              ),
              const Divider(color: AppColors.dividerLight),
              Text(
                currencyFormatter.format(account.balance),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isNegative
                      ? AppColors.expense
                      : AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getAccountTypeName(AccountType type) {
    switch (type) {
      case AccountType.cash:
        return 'Cash';
      case AccountType.bank:
        return 'Bank';
      case AccountType.creditCard:
        return 'Credit Card';
      case AccountType.eWallet:
        return 'E-Wallet';
    }
  }
}
