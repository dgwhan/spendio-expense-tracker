import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/utils/currency_formatter.dart';
import 'package:spend_io_app/features/budget/domain/entities/budget_category_progress_entity.dart';

class BudgetCategoryCard extends StatelessWidget {
  final BudgetCategoryProgressEntity category;
  final VoidCallback? onTap;

  const BudgetCategoryCard({
    super.key,
    required this.category,
    this.onTap,
  });

  // Hệ thống mapping Style dựa hoàn toàn vào `categoryId` (hoặc Category Name nếu bạn có map từ ngoài vào)
  Map<String, dynamic> _getCategoryStyle(String categoryId, bool isDark) {
    MaterialColor baseColor;
    IconData icon;
    String fallbackName = 'Danh mục';

    // Bạn có thể map theo ID cứng của hệ thống hoặc chứa text định danh trong DB
    switch (categoryId.toLowerCase()) {
      case 'dining':
      case 'food':
        baseColor = Colors.orange;
        icon = Icons.restaurant_outlined;
        fallbackName = 'Ăn uống';
        break;
      case 'transport':
        baseColor = Colors.blue;
        icon = Icons.directions_bus_outlined;
        fallbackName = 'Di chuyển';
        break;
      case 'shopping':
        baseColor = Colors.purple;
        icon = Icons.shopping_bag_outlined;
        fallbackName = 'Mua sắm';
        break;
      case 'health':
        baseColor = Colors.red;
        icon = Icons.favorite_border_outlined;
        fallbackName = 'Sức khỏe';
        break;
      case 'bills':
        baseColor = Colors.amber;
        icon = Icons.bolt_outlined;
        fallbackName = 'Hóa đơn';
        break;
      case 'entertainment':
        baseColor = Colors.pink;
        icon = Icons.confirmation_number_outlined;
        fallbackName = 'Giải trí';
        break;
      default:
        baseColor = Colors.grey;
        icon = Icons.category_outlined;
        fallbackName =
            categoryId; // Fallback dùng tạm chính ID nếu chưa map kịp
    }

    final iconColor =
        isDark ? baseColor.withValues(alpha: 0.9) : baseColor.shade700;
    final bgColor = isDark
        ? baseColor.withValues(alpha: 0.15)
        : baseColor.withValues(alpha: 0.08);

    return {
      'displayName': fallbackName,
      'icon': icon,
      'color': iconColor,
      'bgColor': bgColor,
    };
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 🔴 SỬA TẠI ĐÂY: Trỏ đúng vào thuộc tính .categoryId của Entity thực tế
    final style = _getCategoryStyle(category.budgetCategory.categoryId, isDark);

    final spentText = CurrencyFormatter.compact(category.spent);
    final budgetText =
        CurrencyFormatter.compact(category.budgetCategory.amount);
    final progress = category.percentage.clamp(0.0, 1.0);

    final titleColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final subtitleColor = isDark ? AppColors.textMutedDark : Colors.black54;
    final cardBgColor = isDark ? AppColors.surfaceSecondaryDark : Colors.white;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Container(
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER
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
                        style[
                            'displayName'], // Hiển thị tên danh mục thân thiện đã qua mapping
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: titleColor,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // PROGRESS BAR
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor:
                        isDark ? AppColors.borderDark : Colors.grey.shade100,
                    valueColor: AlwaysStoppedAnimation<Color>(style['color']),
                    minHeight: 6,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  '$spentText / $budgetText',
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
