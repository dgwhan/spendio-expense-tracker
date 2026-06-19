import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/utils/currency_formatter.dart';
import 'package:spend_io_app/features/home/data/models/spending_breakdown_model.dart';
import 'package:spend_io_app/features/home/presentation/widgets/spending_breakdown/helpers/breakdown_color_helper.dart';

class BreakdownLegendItem extends StatelessWidget {
  final SpendingItemModel item;

  const BreakdownLegendItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final color = BreakdownColorHelper.getColor(item.name);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceSecondaryLight),
      ),
      child: Row(
        children: [
          // Chấm màu đại diện danh mục
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),

          // ✅ ĐÃ SỬA: Bọc Expanded + Giảm size chữ xuống 2px để ép text không đẩy tung lề ngang
          Expanded(
            child: Text(
              item.name,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 12, // Giảm 2px (Mặc định bodyMedium thường là 14)
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryLight,
                  ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: 12),

          // Số tiền định dạng compact
          Text(
            CurrencyFormatter.compact(item.amount),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 12, // Giảm 2px để đồng bộ không gian hàng dọc
                  color: AppColors.textSecondaryLight,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(width: 16),

          Text(
            '${(item.percentage * 100).toStringAsFixed(0)}%',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryLight,
                ),
          ),
        ],
      ),
    );
  }
}
