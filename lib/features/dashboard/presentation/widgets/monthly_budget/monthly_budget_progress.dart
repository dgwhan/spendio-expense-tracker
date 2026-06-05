import 'package:flutter/material.dart';
import 'package:spend_io_app/core/utils/currency_formatter.dart';
import 'package:spend_io_app/features/dashboard/datasource/models/monthly_budget_model.dart';
import 'package:spend_io_app/features/dashboard/presentation/widgets/shared/dashboard_section_container.dart';
import 'widgets/budget_progress_bar.dart';

class MonthlyBudgetProgress extends StatelessWidget {
  final MonthlyBudgetModel budget;

  const MonthlyBudgetProgress({
    super.key,
    required this.budget,
  });

  @override
  Widget build(BuildContext context) {
    final String remainingText =
        '${CurrencyFormatter.format(budget.remaining)} Left';
    final String spentPercentText =
        '${(budget.progress * 100).toStringAsFixed(0)}% Spent';
    final String totalBudgetText =
        'of ${CurrencyFormatter.format(budget.totalBudget)}';

    final double safeProgress = budget.progress.clamp(0.0, 1.0);

    return DashboardSectionContainer(
      padding: const EdgeInsets.all(16.0),
      child: BudgetProgressBar(
        progress: safeProgress,
        remainingText: remainingText,
        spentPercentText: spentPercentText,
        totalBudgetText: totalBudgetText,
      ),
    );
  }
}
