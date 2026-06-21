import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_radius.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/features/saving_goal/domain/entities/saving_goal_entity.dart';

class SavingGoalsCard extends StatelessWidget {
  final SavingGoalEntity? goal;
  final VoidCallback? onTap;
  final VoidCallback? onAdd;

  const SavingGoalsCard({
    super.key,
    this.goal,
    this.onTap,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final surfaceColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    final titleColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    final subtitleColor =
        isDark ? AppColors.textMutedDark : AppColors.textMutedLight;

    // ================= EMPTY STATE =================
    if (goal == null) {
      return InkWell(
        onTap: onAdd,
        borderRadius: BorderRadius.circular(AppRadius.cardRadiusLg),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.lg),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(AppRadius.cardRadiusLg),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            children: [
              Icon(
                Icons.flag_rounded,
                size: 40,
                color: AppColors.primary.withValues(alpha: 0.7),
              ),
              const SizedBox(height: AppSizes.md),
              Text(
                'No Saving Goals yet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Start building your financial future',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: subtitleColor,
                ),
              ),
              const SizedBox(height: AppSizes.md),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '+ Add Goal',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ================= NORMAL CARD =================
    final goalColor = Color(goal!.colorValue);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.cardRadiusLg),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(AppRadius.cardRadiusLg),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: goalColor.withValues(alpha: .15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    IconData(
                      goal!.iconCodePoint,
                      fontFamily: goal!.iconFontFamily,
                    ),
                    color: goalColor,
                  ),
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal!.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${goal!.cachedCurrentAmount.toStringAsFixed(0)} / '
                        '${goal!.targetAmount.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 13,
                          color: subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${(goal!.cachedProgress * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: goalColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: goal!.cachedProgress,
                minHeight: 8,
                backgroundColor: goalColor.withValues(alpha: .15),
                valueColor: AlwaysStoppedAnimation(goalColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
