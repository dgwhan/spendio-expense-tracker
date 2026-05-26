import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/core/constants/app_assets.dart';
import 'package:spend_io_app/features/onboarding/presentation/widgets/occupation_card.dart';
import '../../viewmodels/onboarding_viewmodel.dart';

class ProfessionPhaseScreen extends StatelessWidget {
  const ProfessionPhaseScreen({super.key});

  static const List<Map<String, dynamic>> occupationsData = [
    {'title': 'Student', 'icon': AppAssets.icStudent},
    {'title': 'Employee', 'icon': AppAssets.icEmployee},
    {'title': 'Freelancer', 'icon': AppAssets.icFreelancer},
    {'title': 'Business Owner', 'icon': AppAssets.icBusiness},
    {'title': 'Other', 'icon': AppAssets.icOther},
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
              'What is your current\noccupation?',
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
              itemCount: occupationsData.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.2,
              ),
              itemBuilder: (context, index) {
                final item = occupationsData[index];
                final String title = item['title'];
                final String iconPath = item['icon'];

                final isSelected = viewModel.occupation == title;

                return OccupationCard(
                  title: title,
                  icon: iconPath,
                  selected: isSelected,
                  onTap: () {
                    viewModel.updateOccupation(title);
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
