import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/features/dashboard/datasource/models/financial_pulse_model.dart';
import 'package:spend_io_app/features/dashboard/presentation/widgets/shared/dashboard_section_container.dart';

import 'widgets/pulse_summary.dart';
import 'widgets/pulse_heatmap.dart';
import 'widgets/pulse_insight_card.dart';

class FinancialPulseSection extends StatelessWidget {
  final FinancialPulseModel pulse;

  const FinancialPulseSection({super.key, required this.pulse});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Tiêu đề phần Financial Pulse hiển thị phía trên hộp vẽ
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Financial Pulse',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryLight,
                    ),
              ),
              // Icon xu hướng trang trí nhỏ trên góc phải thiết kế mẫu
              const Icon(
                Icons.trending_up_rounded,
                color: AppColors.gradientEnd,
                size: 20,
              ),
            ],
          ),
        ),

        DashboardSectionContainer(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PulseSummary(
                totalAmount: pulse.thisWeekTotal,
                comparePercentage: pulse.comparePercentage,
                isDecreased: pulse.isDecreased,
              ),
              const SizedBox(height: 20),
              PulseHeatmap(dailySpendings: pulse.dailySpendings),
              const SizedBox(height: 20),
              PulseInsightCard(
                highestDay: pulse.highestDayName,
                highestAmount: pulse.highestDayAmount,
                topCategory: pulse.topCategoryName,
                topCategoryPercent: pulse.topCategoryPercentage,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
