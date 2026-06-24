import 'package:flutter/material.dart';
import 'package:spend_io_app/core/widgets/button/app_text_button.dart';
import 'package:spend_io_app/features/home/data/models/spending_breakdown_model.dart';
import 'breakdown_legend_item.dart';

class BreakdownLegend extends StatelessWidget {
  final List<SpendingItemModel> items;
  final VoidCallback? onViewMoreTap;

  final int maxVisibleItems;

  const BreakdownLegend({
    super.key,
    required this.items,
    this.onViewMoreTap,
    this.maxVisibleItems =
        3, 
  });

  @override
  Widget build(BuildContext context) {
    // Kiểm tra xem danh sách thực tế có vượt quá hạn mức hiển thị không
    final bool showViewMore = items.length > maxVisibleItems;

    final displayedItems =
        showViewMore ? items.take(maxVisibleItems).toList() : items;

    return Column(
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount:
              displayedItems.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) =>
              BreakdownLegendItem(item: displayedItems[index]),
        ),

        if (showViewMore) ...[
          const SizedBox(height: 16),
          AppTextButton(
            text: 'View More',
            fontSize: 13,
            onTap: onViewMoreTap,
          ),
        ],
      ],
    );
  }
}
