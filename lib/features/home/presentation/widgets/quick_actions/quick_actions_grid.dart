import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/features/home/presentation/widgets/shared/dashboard_section_container.dart';

class QuickActionsGrid extends StatelessWidget {
  final VoidCallback? onTransactionTap;
  final VoidCallback? onBudgetTap;
  final VoidCallback? onAnalyticsTap;
  final VoidCallback? onSavingGoalTap;

  const QuickActionsGrid(
      {super.key,
      this.onTransactionTap,
      this.onBudgetTap,
      this.onAnalyticsTap,
      this.onSavingGoalTap});

  @override
  Widget build(BuildContext context) {
    return DashboardSectionContainer(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          //Transaction
          Expanded(
            child: _ActionItem(
              icon: Icons.add,
              label: 'Transaction',
              onTap: onTransactionTap,
            ),
          ),

          //Budget
          Expanded(
            child: _ActionItem(
              icon: Icons.savings_outlined,
              label: 'Budget',
              onTap: onBudgetTap,
            ),
          ),

          //Analytics
          Expanded(
            child: _ActionItem(
              icon: Icons.bar_chart_outlined,
              label: 'Analytics',
              onTap: onAnalyticsTap,
            ),
          ),

          //Saving Goals
          Expanded(
            child: _ActionItem(
              icon: Icons.savings_outlined,
              label: 'Budget',
              onTap: onBudgetTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ActionItem({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: AppColors.primary.withValues(alpha: 0.1),
      highlightColor: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.borderLight,
                width: 1.5,
              ),
              color: Colors.white,
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondaryLight,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
          ),
        ],
      ),
    );
  }
}
