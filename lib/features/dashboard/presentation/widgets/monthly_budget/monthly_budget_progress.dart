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
    //Tiêu đề động theo tháng
    final String budgetTitle = '${budget.monthName} Budget';

    // Định dạng chuỗi theo ảnh mẫu: Remaining
    final String remainingText =
        'Remaining ${CurrencyFormatter.format(budget.remaining)}';

    // Định dạng chuỗi dưới lề trái: Used % (đã sd / %)
    final String usedPercentText =
        'Used ${(budget.progress * 100).toStringAsFixed(0)}%';

    // Định dạng chuỗi dưới lề phải: Limit (giới hạn số tiền còn lại)
    final String limitText =
        'Limit: ${CurrencyFormatter.format(budget.totalBudget)}';

    final double safeProgress = budget.progress.clamp(0.0, 1.0);

    return DashboardSectionContainer(
      padding: const EdgeInsets.all(16.0),
      child: BudgetProgressBar(
        progress: safeProgress,
        budgetTitle: budgetTitle,
        remainingText: remainingText,
        usedPercentText: usedPercentText,
        limitText: limitText,
      ),
    );
  }
}
