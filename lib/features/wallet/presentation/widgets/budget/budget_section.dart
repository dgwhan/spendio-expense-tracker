import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/utils/date_formatter.dart';
import 'package:spend_io_app/features/wallet/domain/entities/budget_category_entity.dart';
import 'package:spend_io_app/features/wallet/presentation/widgets/budget/monthly_budget_card.dart';
import 'package:spend_io_app/features/wallet/presentation/widgets/budget/wallet_budget_categories_grid.dart';
import 'package:spend_io_app/core/widgets/common/app_section_header.dart';

class BudgetSection extends StatelessWidget {
  final double totalSpent;
  final double totalBudget;
  final int daysLeft;
  final List<BudgetCategoryEntity> categories;

  const BudgetSection({
    super.key,
    required this.totalSpent,
    required this.totalBudget,
    required this.daysLeft,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    final String formattedDate =
        DateFormatter.toMonthYearString(DateTime.now());
    final String currentBudgetTitle = '$formattedDate Budget';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(title: currentBudgetTitle),
        const SizedBox(height: AppSizes.md),
        MonthlyBudgetCard(
          spent: totalSpent,
          budget: totalBudget,
          daysLeft: daysLeft,
        ),
        const SizedBox(height: AppSizes.lg),
        WalletBudgetCategoriesGrid(
          categories: categories,
        ),
      ],
    );
  }
}
