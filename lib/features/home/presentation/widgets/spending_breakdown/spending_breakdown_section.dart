import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/features/home/data/models/spending_breakdown_model.dart';
import 'package:spend_io_app/features/home/presentation/widgets/home_section_container.dart';
import 'package:spend_io_app/core/widgets/button/app_text_button.dart';

import 'widgets/breakdown_filter_tabs.dart';
import 'widgets/breakdown_chart.dart';
import 'widgets/breakdown_legend.dart';

class SpendingBreakdownSection extends StatefulWidget {
  final SpendingBreakdownModel weekData;
  final SpendingBreakdownModel monthData;
  final SpendingBreakdownModel yearData;
  final VoidCallback? onViewDetailTap;
  final VoidCallback? onViewMoreTap;

  const SpendingBreakdownSection({
    super.key,
    required this.weekData,
    required this.monthData,
    required this.yearData,
    this.onViewDetailTap,
    this.onViewMoreTap,
  });

  @override
  State<SpendingBreakdownSection> createState() =>
      _SpendingBreakdownSectionState();
}

class _SpendingBreakdownSectionState extends State<SpendingBreakdownSection> {
  String _activeTab = 'Month';

  SpendingBreakdownModel get _currentBreakdownData {
    switch (_activeTab) {
      case 'Week':
        return widget.weekData;
      case 'Year':
        return widget.yearData;
      case 'Month':
      default:
        return widget.monthData;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeData = _currentBreakdownData;

    final titleTextColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Spending Breakdown',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: titleTextColor,
                    ),
              ),
              AppTextButton(
                text: 'View Detail',
                fontSize: 13,
                onTap: widget.onViewDetailTap,
              ),
            ],
          ),
        ),
        HomeSectionContainer(
          padding: const EdgeInsets.symmetric(
              horizontal: 16.0, vertical: 8.0), // Tối ưu lại khoảng cách đệm
          child: Column(
            children: [
              BreakdownFilterTabs(
                activeTab: _activeTab,
                onTabChanged: (tab) {
                  setState(() {
                    _activeTab = tab;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Biểu đồ hình tròn chứa thông tin động
              BreakdownChart(data: activeData),
              const SizedBox(height: 24),

              // Danh sách chú thích các danh mục chi tiêu
              BreakdownLegend(
                items: activeData.items,
                onViewMoreTap: widget.onViewMoreTap,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
