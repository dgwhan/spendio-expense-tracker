import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/constants/app_text_styles.dart';
import 'package:spend_io_app/core/utils/currency_formatter.dart';
import 'package:spend_io_app/core/currency/currency_context.dart';
import 'package:spend_io_app/core/widgets/app_header.dart';
import 'package:spend_io_app/core/widgets/primary_button.dart';
import 'package:spend_io_app/features/saving_goal/domain/entities/saving_goal_entity.dart';
import 'package:spend_io_app/features/saving_goal/presentation/screens/edit_saving_goal_screen.dart';
import 'package:spend_io_app/features/saving_goal/presentation/viewmodels/saving_goal_detail_viewmodel.dart';
import 'package:spend_io_app/features/saving_goal/presentation/widgets/contribution/add_contribution_bottom_sheet.dart';
import 'package:spend_io_app/features/saving_goal/presentation/widgets/saving_goals_card.dart';

class SavingGoalDetailScreen extends StatefulWidget {
  final String goalId;
  const SavingGoalDetailScreen({super.key, required this.goalId});

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

  Future<void> _handleDelete(SavingGoalEntity goal) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Goal'),
        content: const Text('Are you sure you want to delete this goal?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await context
          .read<SavingGoalDetailViewModel>()
          .deleteGoal(goalId: goal.id, userId: goal.userId);
      if (mounted) Navigator.pop(context, true);
    }
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
        actions: goal != null
            ? [
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  EditSavingGoalScreen(goal: goal)));
                    } else if (value == 'delete') {
                      _handleDelete(goal);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete',
                            style: TextStyle(color: Colors.red))),
                  ],
                )
              ]
            : [],
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
                      SizedBox(
                        width: double.infinity,
                        child: AppButton(
                          title: 'Add Money',
                          onPressed: () => showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (_) => AddContributionBottomSheet(
                              goalId: goal.id,
                              userId: goal.userId,
                              onSubmit: (c) => vm.addContribution(
                                  goalId: goal.id, contribution: c),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSizes.md),
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
              Text('Progress', style: AppTextStyles.sectionTitle),
              Text(
                  '${(goal.cachedProgress * 100).toStringAsFixed(1)}% completed',
                  style: AppTextStyles.caption
                      .copyWith(color: color, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow(context, 'Saved amount',
              formatCurrency(goal.cachedCurrentAmount, currencyCode: goal.currencyCode, locale: context.currencyContext.locale)),
          const SizedBox(height: 16),
          _buildInfoRow(
              context, 'Target goal', formatCurrency(goal.targetAmount, currencyCode: goal.currencyCode, locale: context.currencyContext.locale)),
          const SizedBox(height: 16),
          _buildInfoRow(
              context,
              'Remaining',
              formatCurrency((goal.targetAmount - goal.cachedCurrentAmount)
                  .clamp(0, double.infinity), currencyCode: goal.currencyCode, locale: context.currencyContext.locale),
              isHighlight: true),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value,
      {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: AppTextStyles.caption
                .copyWith(color: Colors.grey, fontSize: 14)),
        Text(value,
            style: AppTextStyles.cardTitle.copyWith(
                fontSize: 20, // Chữ to theo yêu cầu
                fontWeight: FontWeight.w800,
                color: isHighlight ? Theme.of(context).primaryColor : null)),
      ],
    );
  }
}
