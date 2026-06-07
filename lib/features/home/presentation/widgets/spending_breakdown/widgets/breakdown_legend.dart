import 'package:flutter/material.dart';
import 'package:spend_io_app/shared/widgets/buttons/app_text_button.dart';
import 'package:spend_io_app/features/home/datasource/models/spending_breakdown_model.dart';
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
        AppTextButton(
          text: 'View More',
          fontSize: 13,
          onTap: onViewMoreTap,
        ),
      ],
    );
  }
}
