import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/widgets/shake_widget.dart';
import 'package:spend_io_app/features/onboarding/presentation/viewmodels/onboarding_viewmodel.dart';
import 'package:spend_io_app/features/onboarding/presentation/widgets/occupation_card.dart';

class ProfessionPhaseScreen extends StatelessWidget {
  const ProfessionPhaseScreen({super.key});

  static const List<Map<String, dynamic>> occupationsData = [
    {'title': 'Student', 'icon': Icons.school_rounded},
    {'title': 'Employee', 'icon': Icons.badge_rounded},
    {'title': 'Freelancer', 'icon': Icons.laptop_mac_rounded},
    {'title': 'Business Owner', 'icon': Icons.storefront_rounded},
    {'title': 'Other', 'icon': Icons.pending_rounded},
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
              'What is your current\noccupation?',
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
              itemCount: occupationsData.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.20,
              ),
              itemBuilder: (context, index) {
                final item = occupationsData[index];
                final String title = item['title'];
                final IconData iconData = item['icon'];

                final isSelected = viewModel.occupation == title;

                return ShakeWidget(
                  triggerStream: viewModel.shakeStream,
                  child: OccupationCard(
                    title: title,
                    icon: iconData,
                    selected: isSelected,
                    onTap: () {
                      viewModel.updateOccupation(title);
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
