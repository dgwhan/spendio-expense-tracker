import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/utils/currency_formatter.dart';
import 'package:spend_io_app/features/wallet/domain/entities/budget_category_entity.dart';

class BudgetCategoryCard extends StatelessWidget {
  final BudgetCategoryEntity category;
  final VoidCallback? onTap;

  const BudgetCategoryCard({
    super.key,
    required this.category,
    this.onTap,
  });

  //helper màu sắc cho từng category hỗ trợ Dark Mode
  Map<String, dynamic> _getCategoryStyle(String name, bool isDark) {
    MaterialColor baseColor;
    switch (name) {
      case 'Dining':
        baseColor = Colors.orange;
        break;
      case 'Transport':
        baseColor = Colors.blue;
        break;
      case 'Shopping':
        baseColor = Colors.purple;
        break;
      case 'Health':
        baseColor = Colors.red;
        break;
      case 'Bills':
        baseColor = Colors.amber;
        break;
      case 'Entertainment':
        baseColor = Colors.pink;
        break;
      default:
        baseColor = Colors.grey;
    }

    final iconColor = isDark ? baseColor.withValues(alpha: 0.9) : baseColor.shade700;
    final bgColor = isDark
        ? baseColor.withValues(alpha: 0.15)
        : baseColor.withValues(alpha: 0.08);

    IconData icon;
    switch (name) {
      case 'Dining':
        icon = Icons.restaurant_outlined;
        break;
      case 'Transport':
        icon = Icons.directions_bus_outlined;
        break;
      case 'Shopping':
        icon = Icons.shopping_bag_outlined;
        break;
      case 'Health':
        icon = Icons.favorite_border_outlined;
        break;
      case 'Bills':
        icon = Icons.bolt_outlined;
        break;
      case 'Entertainment':
        icon = Icons.confirmation_number_outlined;
        break;
      default:
        icon = Icons.category_outlined;
    }

    return {
      'icon': icon,
      'color': iconColor,
      'bgColor': bgColor,
    };
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final style = _getCategoryStyle(category.name, isDark);

    final String spentText = CurrencyFormatter.compact(category.spent);
    final String budgetText = CurrencyFormatter.compact(category.budget);

    final double safeProgress = category.progress.clamp(0.0, 1.0);

    final titleColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final subtitleColor = isDark ? AppColors.textMutedDark : Colors.black54;
    final cardBgColor = isDark ? AppColors.surfaceSecondaryDark : Colors.white;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Container(
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                //icon, tên danh mục
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: style['bgColor'],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        style['icon'],
                        color: style['color'],
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        category.name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: titleColor,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                //thanh tiến trình, số tiền
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: safeProgress,
                        backgroundColor: isDark ? AppColors.borderDark : Colors.grey.shade100,
                        valueColor: AlwaysStoppedAnimation<Color>(style['color']),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$spentText / $budgetText',
                      style: TextStyle(
                        color: subtitleColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
