import 'package:flutter/material.dart';
import 'package:spend_io_app/features/budget/presentation/screens/budget_detail_screen.dart';
import 'monthly_budget_card.dart';
import 'empty_monthly_budget_card.dart';

class MonthlyBudgetCardContainer extends StatelessWidget {
  final double totalSpent;
  final double totalBudget;
  final int daysLeft;
  final int userId;

  const MonthlyBudgetCardContainer({
    super.key,
    required this.totalSpent,
    required this.totalBudget,
    required this.daysLeft,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = totalBudget - totalSpent;
    final percentage =
        totalBudget > 0 ? (totalSpent / totalBudget).clamp(0.0, 1.0) : 0.0;

    final Widget cardChild = totalBudget <= 0
        ? const EmptyMonthlyBudgetCard()
        : MonthlyBudgetCard(
            totalSpent: totalSpent,
            totalBudget: totalBudget,
            remaining: remaining,
            percentage: percentage,
            daysLeft: daysLeft,
            userId: userId,
            onTap: null,
          );

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BudgetDetailScreen(
              totalSpent: totalSpent,
              totalBudget: totalBudget,
              daysLeft: daysLeft,
              userId: userId,
            ),
          ),
        );
      },
      child: cardChild,
    );
  }
}
