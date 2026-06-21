import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/widgets/common/app_empty_state.dart';
import 'package:spend_io_app/features/saving_goal/domain/entities/saving_goal_entity.dart';
import 'package:spend_io_app/features/saving_goal/presentation/widgets/saving_goals_card.dart';

class GoalsSection extends StatelessWidget {
  final List<SavingGoalEntity> goals;
  final VoidCallback onViewAll;
  final VoidCallback onAddGoal;
  final Function(SavingGoalEntity)? onGoalTap;

  const GoalsSection({
    super.key,
    required this.goals,
    required this.onViewAll,
    required this.onAddGoal,
    this.onGoalTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    final displayLimit = goals.length > 2 ? 2 : goals.length;
    final displayGoals = goals.take(displayLimit).toList();
    final remaining = goals.length - displayLimit;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Savings Goals',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: primaryTextColor,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onAddGoal,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withValues(alpha: 0.1),
                    ),
                    child: Icon(
                      Icons.add_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            IconButton(
              onPressed: onViewAll,
              icon: Icon(
                Icons.chevron_right_rounded,
                color: AppColors.primary,
                size: 22,
              ),
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (goals.isEmpty)
          AppEmptyState(
            title: 'No Saving Goals',
            subtitle: 'Create your first goal\nand start saving today.',
            icon: Icons.flag_rounded,
            actionLabel: 'Create Goal',
            onActionTap: onAddGoal,
            isBordered: true,
          )
        else ...[
          ...displayGoals.asMap().entries.map(
            (entry) {
              final index = entry.key;
              final goal = entry.value;
              final isLast = index == displayGoals.length - 1 && remaining <= 0;

              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : AppSizes.md),
                child: SavingGoalsCard(
                  goal: goal,
                  onTap: () => onGoalTap?.call(goal),
                ),
              );
            },
          ),
          if (remaining > 0)
            Padding(
              padding: const EdgeInsets.only(top: AppSizes.xs),
              child: InkWell(
                onTap: onViewAll,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '+$remaining more goal${remaining > 1 ? "s" : ""}',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ],
    );
  }
}
