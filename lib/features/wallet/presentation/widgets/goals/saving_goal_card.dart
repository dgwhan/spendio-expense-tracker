import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_radius.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/features/wallet/domain/entities/saving_goal_entity.dart';

import 'package:spend_io_app/features/wallet/presentation/widgets/goals/widgets/goal_estimated_date.dart';
import 'package:spend_io_app/features/wallet/presentation/widgets/goals/widgets/goal_progress_info.dart';
import 'package:spend_io_app/features/wallet/presentation/widgets/goals/widgets/goal_target_info.dart';

class SavingGoalCard extends StatelessWidget {
  final SavingGoalEntity goal;

  const SavingGoalCard({
    super.key,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    //Tính % tiến độ: Tránh chia cho 0 và giới hạn giá trị trong khoảng [0.0 - 1.0] (0% - 100%) bằng .clamp
    final double progress = (goal.targetAmount > 0)
        ? (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0)
        : 0.0;

    final bool isEmergency = goal.name.toLowerCase().contains('emergency');
    final Color themeColor =
        isEmergency ? AppColors.success : AppColors.primary;
    final Color iconBgColor = themeColor.withValues(alpha: 0.15);

    final backgroundColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final titleTextColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      padding: const EdgeInsets.all(AppSizes.md * 1.2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  goal.icon,
                  color: themeColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: titleTextColor,
                      ),
                    ),
                    const SizedBox(height: AppSizes.xs),
                    GoalEstimatedDate(estimatedDate: goal.estimatedDate),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          GoalProgressInfo(
            progress: progress,
            progressColor: themeColor,
          ),
          const SizedBox(height: AppSizes.sm),
          GoalTargetInfo(
            currentAmount: goal.currentAmount,
            targetAmount: goal.targetAmount,
          ),
        ],
      ),
    );
  }
}
