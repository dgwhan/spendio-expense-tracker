import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_radius.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/utils/account_type_ext.dart';
import 'package:spend_io_app/core/utils/currency_formatter.dart';
import 'package:spend_io_app/features/wallet/domain/entities/account_entity.dart';
import 'package:spend_io_app/features/wallet/presentation/widgets/accounts/widgets/account_icon_container.dart';

class AccountItemCard extends StatelessWidget {
  final AccountEntity account;
  final VoidCallback? onTap;

  const AccountItemCard({
    super.key,
    required this.account,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color mainColor = account.type.mainColor;
    final Color bgColor = account.type.bgColor;
    final isNegative = account.balance < 0;

    final cardBgColor = isDark ? AppColors.surfaceSecondaryDark : AppColors.surfaceCardLight;
    final mutedTextColor = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
    final primaryTextColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Container(
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(AppRadius.cardRadiusLg),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.cardRadiusLg),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.lg,
            vertical: AppSizes.md * 1.2,
          ),
          child: Row(
            children: [
              AccountIconContainer(
                icon: account.icon,
                iconColor: mainColor,
                backgroundColor: bgColor,
              ),
              const SizedBox(width: AppSizes.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.type.displayName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: mutedTextColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyFormatter.format(account.balance),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isNegative
                          ? AppColors.expense
                          : primaryTextColor,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Icon(
                Icons.chevron_right,
                color: mutedTextColor,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
