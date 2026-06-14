import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_radius.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/utils/account_type_ext.dart';
import 'package:spend_io_app/core/utils/currency_formatter.dart';
import 'package:spend_io_app/features/account/domain/entities/account_entity.dart';

class AccountBalanceCard extends StatelessWidget {
  final AccountEntity account;

  const AccountBalanceCard({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    final Color typeColor = account.type.mainColor;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.lg * 1.2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            typeColor,
            typeColor.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.cardRadiusLg),
        boxShadow: [
          BoxShadow(
            color: typeColor.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.sm),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.24),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  account.icon,
                  color: AppColors.white,
                  size: 28,
                ),
              ),
              Text(
                account.type.displayName.toUpperCase(),
                style: TextStyle(
                  color: AppColors.white.withValues(alpha: 0.7),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.xl * 1.2),
          Text(
            'CURRENT BALANCE',
            style: TextStyle(
              color: AppColors.white.withValues(alpha: 0.6),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            CurrencyFormatter.format(account.balance),
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
