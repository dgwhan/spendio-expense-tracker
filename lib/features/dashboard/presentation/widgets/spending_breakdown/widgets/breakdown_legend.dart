import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/features/dashboard/datasource/models/spending_breakdown_model.dart';
import 'breakdown_legend_item.dart';

class BreakdownLegend extends StatelessWidget {
  final List<SpendingItemModel> items;
  final VoidCallback? onViewMoreTap;

  const BreakdownLegend({
    super.key,
    required this.items,
    this.onViewMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) =>
              BreakdownLegendItem(item: items[index]),
        ),

        //btn View More
        const SizedBox(height: 16),
        TextButton(
          onPressed: onViewMoreTap,
          child: const Text(
            'View More',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}
