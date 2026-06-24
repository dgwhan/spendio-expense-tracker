import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/features/home/presentation/widgets/home_section_container.dart';

class QuickActionsGrid extends StatelessWidget {
  final VoidCallback? onCreateBudgetTap;
  final VoidCallback? onTransactionHistoryTap;
  final VoidCallback? onManageSavingsTap;
  final VoidCallback? onInsightsTap;
  final VoidCallback? onMonthlyBudgetTap;
  final VoidCallback? onCategoryManagementTap;

  const QuickActionsGrid({
    super.key,
    this.onCreateBudgetTap,
    this.onTransactionHistoryTap,
    this.onManageSavingsTap,
    this.onInsightsTap,
    this.onMonthlyBudgetTap,
    this.onCategoryManagementTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    return Theme(
      data: Theme.of(context).copyWith(
        cardColor: cardBgColor,
      ),
      child: HomeSectionContainer(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          mainAxisSpacing: 16,
          crossAxisSpacing: 8,
          childAspectRatio: 0.85,
          children: [
            _ActionItem(
              icon: Icons.history_rounded,
              label: 'Transaction\nHistory',
              onTap: () {
                debugPrint('[QUICK ACTION] Clicked: Transaction History');
                onTransactionHistoryTap?.call();
              },
              isDark: isDark,
            ),
            _ActionItem(
              icon: Icons.track_changes_rounded,
              label: 'Savings\nGoals',
              onTap: () {
                debugPrint('[QUICK ACTION] Clicked: Savings Goals');
                onManageSavingsTap?.call();
              },
              isDark: isDark,
            ),
            _ActionItem(
              icon: Icons.calendar_month_rounded,
              label: 'Monthly\nBudget',
              onTap: () {
                debugPrint('[QUICK ACTION] Clicked: Monthly Budget');
                onMonthlyBudgetTap?.call();
              },
              isDark: isDark,
            ),
            _ActionItem(
              icon: Icons.grid_view_rounded,
              label: 'Category\nManage',
              onTap: () {
                debugPrint('[QUICK ACTION] Clicked: Category Management');
                onCategoryManagementTap?.call();
              },
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isDark;

  const _ActionItem({
    required this.icon,
    required this.label,
    required this.isDark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final containerBg = isDark
        ? AppColors.surfaceSecondaryDark
        : Colors.grey.withValues(alpha: 0.05);
    final textColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return InkWell(
      onTap: onTap,
      splashColor: AppColors.primary.withValues(alpha: 0.1),
      highlightColor: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: containerBg,
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 34,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    height: 1.2,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
