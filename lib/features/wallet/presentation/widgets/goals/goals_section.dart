import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/features/wallet/presentation/viewmodels/wallet_viewmodel.dart';
import 'package:spend_io_app/shared/headers/app_section_header.dart';
import 'package:spend_io_app/shared/states/section_empty_state.dart';
import 'saving_goal_card.dart';

class GoalsSection extends StatelessWidget {
  const GoalsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final liveGoals = context.watch<WalletViewModel>().goals;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(
          title: 'Savings Goals',
          fontSize: 26,
          actionLabel: 'Add',
          onActionTap: () {
            // TODO: Xử lý thêm mục tiêu tiết kiệm mới
          },
        ),
        const SizedBox(height: AppSizes.md),

        // XỬ LÝ ĐIỀU KIỆN EMPTY STATE (PR-09)
        liveGoals.isEmpty
            ? SectionEmptyState(
                title: 'No Saving Goals',
                subtitle: 'Create a goal and start\nbuilding your future.',
                icon: Icons.track_changes_outlined,
                actionLabel: 'Create Goal',
                onActionTap: () {
                  // TODO: Hành động thêm mục tiêu nhanh từ Empty State
                },
              )
            : Column(
                children: liveGoals
                    .map((goal) => SavingGoalCard(goal: goal))
                    .toList(),
              ),
      ],
    );
  }
}
