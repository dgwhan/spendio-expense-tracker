import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/utils/currency_formatter.dart';
import 'package:spend_io_app/features/home/datasource/models/budget_category_model.dart';

class BudgetCategoryCard extends StatelessWidget {
  final BudgetCategoryModel category;

  const BudgetCategoryCard({
    super.key,
    required this.category,
  });

  //helper màu sắc cho từng category
  Map<String, dynamic> _getCategoryStyle(String name) {
    switch (name) {
      case 'Dining':
        return {
          'icon': Icons.restaurant_outlined,
          'color': Colors.orange.shade700,
          'bgColor': Colors.orange.shade50,
        };
      case 'Transport':
        return {
          'icon': Icons.directions_bus_outlined,
          'color': Colors.blue.shade700,
          'bgColor': Colors.blue.shade50,
        };
      case 'Shopping':
        return {
          'icon': Icons.shopping_bag_outlined,
          'color': Colors.purple.shade700,
          'bgColor': Colors.purple.shade50,
        };
      case 'Health':
        return {
          'icon': Icons.favorite_border_outlined,
          'color': Colors.red.shade700,
          'bgColor': Colors.red.shade50,
        };
      case 'Bills':
        return {
          'icon': Icons.bolt_outlined,
          'color': Colors.amber.shade800,
          'bgColor': Colors.amber.shade50,
        };
      case 'Entertainment':
        return {
          'icon': Icons.confirmation_number_outlined,
          'color': Colors.pink.shade700,
          'bgColor': Colors.pink.shade50,
        };
      default:
        return {
          'icon': Icons.category_outlined,
          'color': Colors.grey.shade700,
          'bgColor': Colors.grey.shade50,
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _getCategoryStyle(category.name);

    final String spentText = CurrencyFormatter.compact(category.spent);
    final String budgetText = CurrencyFormatter.compact(category.budget);

    final double safeProgress = category.progress.clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderLight,
        ),
      ),
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
                        color: AppColors.textPrimaryLight,
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
                  backgroundColor: Colors.grey.shade100,
                  valueColor: AlwaysStoppedAnimation<Color>(style['color']),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$spentText / $budgetText',
                style: const TextStyle(
                  color: Colors.black54,
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
    );
  }
}
