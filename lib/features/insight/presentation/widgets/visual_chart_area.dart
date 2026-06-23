import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/features/insight/presentation/viewmodels/insight_state.dart';
import 'package:spend_io_app/features/insight/presentation/widgets/insight_bar_chart.dart';

class VisualChartArea extends StatelessWidget {
  final InsightState state;

  const VisualChartArea({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.barItems.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.md),
      sliver: SliverToBoxAdapter(
        child: InsightBarChart(items: state.barItems),
      ),
    );
  }
}
