import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_radius.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/utils/currency_formatter.dart';
import 'package:spend_io_app/features/transaction/data/models/transaction_model.dart';
import 'package:spend_io_app/features/transaction/presentation/screen/utils/transaction_ui_mapper.dart';

/// [App Location] Account Details Screen: Under each date group section.
/// [Core Function] Displays an individual transaction row with dynamic category icon/color, title, timestamp, and adaptive color-coded amount.
class AccountDetailTransactionTile extends StatelessWidget {
  final TransactionModel tx;

  const AccountDetailTransactionTile({super.key, required this.tx});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedTextColor =
        isDark ? AppColors.textMutedDark : AppColors.textMutedLight;

    final formattedAmount = CurrencyFormatter.format(tx.amount);
    final timeStr = DateFormat('HH:mm').format(tx.date);

    // DYNAMIC LOOKUP: Read icon and colors directly from the transaction object
    // to support upcoming user-defined custom categories.
    final IconData categoryIcon = tx.categoryIcon;
    final Color categoryColor = tx.categoryColor ??
        (isDark ? AppColors.categoryOtherDark : AppColors.categoryOtherLight);
    final Color categoryBgColor = tx.categoryBgColor ??
        (isDark
            ? AppColors.categoryOtherBgDark
            : AppColors.categoryOtherBgLight);

    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: 8.0, horizontal: AppSizes.md),
      child: Row(
        children: [
          // Dynamic Category Icon Container
          Container(
            padding: const EdgeInsets.all(AppSizes.sm),
            decoration: BoxDecoration(
              color: categoryBgColor,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              categoryIcon,
              color: categoryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSizes.md),

          // Transaction Information Block
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${tx.category} • $timeStr',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: mutedTextColor,
                  ),
                ),
              ],
            ),
          ),

          // Flow Amount Text (Adaptive Inflow/Outflow color)
          Text(
            '${tx.isExpense ? "-" : "+"}$formattedAmount',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: tx.isExpense
                  ? (isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight)
                  : AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}
