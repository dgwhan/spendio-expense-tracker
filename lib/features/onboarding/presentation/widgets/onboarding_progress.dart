import 'package:flutter/material.dart';

class OnboardingProgress extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const OnboardingProgress({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (index) {
        final isActive = index <= currentStep;

        return Expanded(
          child: Container(
            height: 6,
            margin: EdgeInsets.symmetric(
              horizontal: index == totalSteps - 1 ? 0 : 4,
            ),
            decoration: BoxDecoration(
              color:
                  isActive ? const Color(0xFF6366F1) : const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        );
      }),
    );
  }
}
