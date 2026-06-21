import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/features/saving_goal/presentation/screens/edit_saving_goal_screen.dart';
import 'package:spend_io_app/features/saving_goal/presentation/viewmodels/saving_goal_detail_viewmodel.dart';
import 'package:spend_io_app/features/saving_goal/presentation/widgets/contribution/add_contribution_bottom_sheet.dart';
import 'package:spend_io_app/features/saving_goal/presentation/widgets/saving_goals_card.dart';
import 'package:spend_io_app/core/widgets/app_header.dart';
import 'package:spend_io_app/core/utils/currency_formatter.dart';

class SavingGoalDetailScreen extends StatefulWidget {
  final String goalId;

  const SavingGoalDetailScreen({
    super.key,
    required this.goalId,
  });

  @override
  State<SavingGoalDetailScreen> createState() => _SavingGoalDetailScreenState();
}

class _SavingGoalDetailScreenState extends State<SavingGoalDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SavingGoalDetailViewModel>().loadGoal(goalId: widget.goalId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SavingGoalDetailViewModel>();
    final goal = vm.goal;

    return Scaffold(
      appBar: AppHeader(
        title: 'Goal Detail',
        showBack: true,
        onBack: () => Navigator.pop(context),
      ),
      body: vm.loading
          ? const Center(child: CircularProgressIndicator())
          : goal == null
              ? const Center(child: Text('Goal not found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSizes.md),
                  child: Column(
                    children: [
                      SavingGoalsCard(goal: goal),
                      const SizedBox(height: AppSizes.lg),
                      _ProgressSection(goal: goal),
                      const SizedBox(height: AppSizes.lg),
                      _ActionSection(
                        onAdd: () {
                          debugPrint(' Add contribution');

                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (_) {
                              final currentVm =
                                  context.read<SavingGoalDetailViewModel>();

                              return AddContributionBottomSheet(
                                goalId: currentVm.goal!.id,
                                userId: currentVm.goal!.userId,
                                onSubmit: (contribution) {
                                  currentVm.addContribution(
                                    goalId: currentVm.goal!.id,
                                    contribution: contribution,
                                  );
                                },
                              );
                            },
                          );
                        },
                        onEdit: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditSavingGoalScreen(
                                goal: goal,
                              ),
                            ),
                          );

                          if (result == true && context.mounted) {
                            context
                                .read<SavingGoalDetailViewModel>()
                                .loadGoal(goalId: goal.id);
                          }
                        },
                        onDelete: () async {
                          final currentVm =
                              context.read<SavingGoalDetailViewModel>();
                          final currentGoal = currentVm.goal;

                          if (currentGoal == null) return;

                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (dialogContext) => AlertDialog(
                              title: const Text('Delete Goal'),
                              content: const Text(
                                  'Are you sure you want to delete this goal?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(dialogContext, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(dialogContext, true),
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (confirm != true) return;

                          try {
                            await currentVm.deleteGoal(
                              goalId: currentGoal.id,
                              userId: currentGoal.userId,
                            );

                            if (!context.mounted) return;
                            Navigator.pop(context, true);
                          } catch (e) {
                            debugPrint('delete error: $e');
                          }
                        },
                      ),
                    ],
                  ),
                ),
    );
  }
}

class _ProgressSection extends StatelessWidget {
  final dynamic goal;

  const _ProgressSection({required this.goal});

  @override
  Widget build(BuildContext context) {
    final color = Color(goal.colorValue);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progress',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${(goal.cachedProgress * 100).toStringAsFixed(1)}% completed',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Saved Amount',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatCurrency(goal.cachedCurrentAmount),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Target Goal',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatCurrency(goal.targetAmount),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionSection extends StatelessWidget {
  final VoidCallback onAdd;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ActionSection({
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Add Money'),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onEdit,
                child: const Text('Edit'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton(
                onPressed: onDelete,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                child: const Text('Delete'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
