import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_radius.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/utils/currency_formatter.dart';
import 'package:spend_io_app/features/home/data/models/recent_transaction_model.dart';

class AccountDetailTransactionTile extends StatelessWidget {
  final RecentTransactionModel tx;

  const AccountDetailTransactionTile({super.key, required this.tx});

  Map<String, dynamic> _getCategoryStyle(String category, bool isDark) {
    switch (category) {
      case 'Food & Drink':
        return {
          'icon': Icons.local_dining_outlined,
          'color': isDark ? AppColors.categoryFoodDrinkDark : AppColors.categoryFoodDrinkLight,
          'bgColor': isDark ? AppColors.categoryFoodDrinkBgDark : AppColors.categoryFoodDrinkBgLight,
        };
      case 'Transport':
        return {
          'icon': Icons.directions_bike_outlined,
          'color': isDark ? AppColors.categoryTransportDark : AppColors.categoryTransportLight,
          'bgColor': isDark ? AppColors.categoryTransportBgDark : AppColors.categoryTransportBgLight,
        };
      case 'Groceries':
        return {
          'icon': Icons.shopping_basket_outlined,
          'color': isDark ? AppColors.categoryGroceriesDark : AppColors.categoryGroceriesLight,
          'bgColor': isDark ? AppColors.categoryGroceriesBgDark : AppColors.categoryGroceriesBgLight,
        };
      case 'Bills':
        return {
          'icon': Icons.receipt_long_outlined,
          'color': isDark ? AppColors.categoryBillsDark : AppColors.categoryBillsLight,
          'bgColor': isDark ? AppColors.categoryBillsBgDark : AppColors.categoryBillsBgLight,
        };
      case 'Shopping':
        return {
          'icon': Icons.shopping_bag_outlined,
          'color': isDark ? AppColors.categoryShoppingDark : AppColors.categoryShoppingLight,
          'bgColor': isDark ? AppColors.categoryShoppingBgDark : AppColors.categoryShoppingBgLight,
        };
      case 'Salary':
        return {
          'icon': Icons.monetization_on_outlined,
          'color': isDark ? AppColors.categorySalaryDark : AppColors.categorySalaryLight,
          'bgColor': isDark ? AppColors.categorySalaryBgDark : AppColors.categorySalaryBgLight,
        };
      default:
        return {
          'icon': Icons.receipt_long_outlined,
          'color': isDark ? AppColors.categoryOtherDark : AppColors.categoryOtherLight,
          'bgColor': isDark ? AppColors.categoryOtherBgDark : AppColors.categoryOtherBgLight,
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final style = _getCategoryStyle(tx.category, isDark);
    final primaryTextColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedTextColor = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
    
    final formattedAmount = CurrencyFormatter.format(tx.amount);
    final timeStr = DateFormat('HH:mm').format(tx.date);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: AppSizes.md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.sm),
            decoration: BoxDecoration(
              color: style['bgColor'],
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              style['icon'],
              color: style['color'],
              size: 20,
            ),
          ),
          const SizedBox(width: AppSizes.md),
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
          Text(
            '${tx.isExpense ? "-" : "+"}$formattedAmount',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: tx.isExpense 
                  ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight) 
                  : AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}
