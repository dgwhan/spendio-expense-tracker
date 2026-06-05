import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/features/dashboard/datasource/models/savings_goal_model.dart';
import 'package:spend_io_app/features/dashboard/presentation/widgets/shared/dashboard_section_container.dart';

import 'widgets/goal_icon.dart';
import 'widgets/goal_status_badge.dart';
import 'widgets/goal_amount_info.dart';
import 'widgets/goal_progress_bar.dart';

class SavingsGoalCard extends StatefulWidget {
  final List<SavingsGoalModel> goals;
  final VoidCallback? onViewAllTap;

  const SavingsGoalCard({
    super.key,
    required this.goals,
    this.onViewAllTap,
  });

  @override
  State<SavingsGoalCard> createState() => _SavingsGoalCardState();
}

class _SavingsGoalCardState extends State<SavingsGoalCard> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    // Đỉnh cao responsive nằm ở đây: controller này ép mỗi page chiếm 84% chiều rộng,
    // vừa vặn chừa khoảng trống cho card sau ló đầu ra y hệt ảnh mẫu!
    _pageController = PageController(viewportFraction: 0.84);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        //tiêu đề
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Savings',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryLight,
                    ),
              ),
              TextButton(
                onPressed: widget.onViewAllTap,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),

        // CAROUSEL VUỐT NGANG
        SizedBox(
          height: 155,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.goals.length,
            padEnds: false,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final goal = widget.goals[index];
              final percentStr = '${(goal.progress * 100).toStringAsFixed(0)}%';

              return Padding(
                padding:
                    const EdgeInsets.only(left: 16.0, right: 4.0, bottom: 4.0),
                child: DashboardSectionContainer(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Cụm trên: Icon + Tên + Badge + Ba chấm
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GoalIcon(iconType: goal.iconType),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  goal.title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimaryLight,
                                      ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  goal.category,
                                  style: TextStyle(
                                    color: AppColors.textSecondaryLight,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          GoalStatusBadge(status: goal.status),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.more_vert_rounded),
                            color: AppColors.textMutedLight,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            style: IconButton.styleFrom(
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                        ],
                      ),

                      // Hàng dưới: số tiền đạt được và tỷ lệ phần trăm
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          GoalAmountInfo(
                              current: goal.currentAmount,
                              target: goal.targetAmount),
                          Text(
                            percentStr,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: goal.iconType == 'vehicle'
                                  ? AppColors.warning
                                  : AppColors.success,
                            ),
                          ),
                        ],
                      ),

                      //thanh goal progress
                      GoalProgressBar(
                          progress: goal.progress, iconType: goal.iconType),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
