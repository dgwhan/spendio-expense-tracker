import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/constants/app_text_styles.dart';
import 'package:spend_io_app/core/currency/currency_context.dart';
import 'package:spend_io_app/core/utils/currency_formatter.dart';
import 'package:spend_io_app/core/widgets/common/app_empty_state.dart';
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
    final titleColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final subtitleColor =
        isDark ? AppColors.textMutedDark : AppColors.textMutedLight;

    // ================= EMPTY STATE =================
    if (goal == null) {
      return AppEmptyState(
        title: 'No Saving Goals',
        subtitle: 'Create your first goal\nand start saving today.',
        icon: Icons.flag_rounded,
        actionLabel: 'Create Goal',
        onActionTap: onAdd,
        isBordered: true,
      );
    }

    // ================= NORMAL CARD =================
    final goalColor = Color(goal!.colorValue);

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: goalColor.withValues(alpha: .08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        IconData(
                          goal!.iconCodePoint,
                          fontFamily: goal!.iconFontFamily,
                        ),
                        color: goalColor,
                        size: 20,
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
                            style: AppTextStyles.cardTitle
                                .copyWith(color: titleColor),
                          ),
                          const SizedBox(height: 2),
                          // SỬ DỤNG FORMATTER TẠI ĐÂY
                          Text(
                            '${formatCurrency(goal!.cachedCurrentAmount, currencyCode: goal!.currencyCode, locale: context.currencyContext.locale)} / '
                            '${formatCurrency(goal!.targetAmount, currencyCode: goal!.currencyCode, locale: context.currencyContext.locale)}',
                            style: AppTextStyles.caption
                                .copyWith(color: subtitleColor),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSizes.sm),
                    Text(
                      '${(goal!.cachedProgress * 100).toStringAsFixed(0)}%',
                      style: AppTextStyles.percentIndicator
                          .copyWith(color: goalColor),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: goal!.cachedProgress,
                    minHeight: 5,
                    backgroundColor: isDark
                        ? AppColors.surfaceSecondaryDark
                        : AppColors.surfaceSecondaryLight,
                    valueColor: AlwaysStoppedAnimation(goalColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
