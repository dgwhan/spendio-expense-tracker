import 'package:flutter/material.dart';
import 'package:spend_io_app/features/home/data/models/spending_breakdown_model.dart';
import 'package:spend_io_app/features/home/presentation/widgets/spending_breakdown/helpers/breakdown_color_helper.dart';
import 'package:spend_io_app/shared/charts/donut_chart.dart';
import 'breakdown_center_info.dart';

class BreakdownChart extends StatelessWidget {
  final SpendingBreakdownModel data;

  const BreakdownChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final donutSections = data.items.map((item) {
      return DonutSectionData(
        value: item.percentage,
        color: BreakdownColorHelper.getColor(item.name),
      );
    }).toList();

    return DonutChart(
      sections: donutSections,
      strokeWidth: 14,
      centerWidget: BreakdownCenterInfo(
        title: data.periodTitle,
        totalAmount: data.totalAmount,
      ),
    );
  }
}
