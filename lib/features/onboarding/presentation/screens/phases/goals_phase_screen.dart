import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/core/constants/app_assets.dart';
import '../../viewmodels/onboarding_viewmodel.dart';
import '../../widgets/goal_card.dart';

class GoalsPhaseScreen extends StatelessWidget {
  const GoalsPhaseScreen({super.key});

  static const List<Map<String, dynamic>> goalsData = [
    {'title': 'Quick Notes', 'icon': AppAssets.icQuickNotes},
    {'title': 'Savings Goals', 'icon': AppAssets.icSavingsGoals},
    {'title': 'Loan Tracking', 'icon': AppAssets.icLoanTracking},
    {'title': 'Expense Management', 'icon': AppAssets.icExpenseManagement},
    {'title': 'Budget Planning', 'icon': AppAssets.icBudgetPlanning},
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingViewModel>(
      builder: (context, viewModel, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'How would you like\nto start?',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
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
                final String? iconPath = item['icon'];

                final isSelected = viewModel.goals.contains(title);

                return GoalCard(
                  title: title,
                  icon: iconPath,
                  selected: isSelected,
                  onTap: () {
                    viewModel.toggleGoal(title);
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }
}
