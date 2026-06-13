import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/features/wallet/presentation/viewmodels/wallet_viewmodel.dart';
import 'package:spend_io_app/shared/headers/app_section_header.dart';
import 'package:spend_io_app/shared/states/section_empty_state.dart';
import 'saving_goal_card.dart';
import 'add_goal_bottom_sheet.dart';

class GoalsSection extends StatelessWidget {
  const GoalsSection({super.key});

  void _showAddGoalDialog(BuildContext context, WalletViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddGoalBottomSheet(viewModel: viewModel),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<WalletViewModel>();
    final liveGoals = viewModel.goals;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(
          title: 'Savings Goals',
          fontSize: 26,
          actionLabel: 'Add',
          onActionTap: () {
            _showAddGoalDialog(context, viewModel);
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
                  _showAddGoalDialog(context, viewModel);
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
