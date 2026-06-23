import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/widgets/shake_widget.dart';
import 'package:spend_io_app/features/onboarding/presentation/viewmodels/onboarding_viewmodel.dart';
import 'package:spend_io_app/features/onboarding/presentation/widgets/goal_card.dart';

class GoalsPhaseScreen extends StatelessWidget {
  const GoalsPhaseScreen({super.key});

  static const List<Map<String, dynamic>> goalsData = [
    {'title': 'Quick Notes', 'icon': Icons.edit_note_rounded},
    {'title': 'Savings Goals', 'icon': Icons.savings_rounded},
    {'title': 'Loan Tracking', 'icon': Icons.credit_score_rounded},
    {
      'title': 'Expense Management',
      'icon': Icons.account_balance_wallet_rounded
    },
    {'title': 'Budget Planning', 'icon': Icons.insights_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<OnboardingViewModel>(
      builder: (context, viewModel, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'How would you like\nto start?',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 32),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: goalsData.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.15,
              ),
              itemBuilder: (context, index) {
                final item = goalsData[index];
                final String title = item['title'];
                final IconData iconData = item['icon'];

                final isSelected = viewModel.goals.contains(title);

                return ShakeWidget(
                  triggerStream: viewModel.shakeStream,
                  child: GoalCard(
                    title: title,
                    icon: iconData,
                    selected: isSelected,
                    onTap: () {
                      viewModel.toggleGoal(title);
                    },
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
