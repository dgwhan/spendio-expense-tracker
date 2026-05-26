import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/features/onboarding/presentation/screens/onboarding_shell_screen.dart';
import 'package:spend_io_app/features/onboarding/presentation/screens/phases/currency_and_balance_screen.dart';
import 'package:spend_io_app/features/onboarding/presentation/screens/phases/goals_phase_screen.dart';
import 'package:spend_io_app/features/onboarding/presentation/screens/phases/identity_phase_screen.dart';
import 'package:spend_io_app/features/onboarding/presentation/screens/phases/profession_phase_screen.dart';
import '../viewmodels/onboarding_viewmodel.dart';

class OnboardingFlowScreen extends StatelessWidget {
  final String userEmail;

  const OnboardingFlowScreen({
    super.key,
    required this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<OnboardingViewModel>();
    final int currentStep = viewModel.currentStep;
    const int totalSteps = 4;

    final List<Widget> steps = [
      IdentityPhaseScreen(userEmail: userEmail),
      const ProfessionPhaseScreen(),
      const GoalsPhaseScreen(),
      const CurrencyAndBalanceScreen(),
    ];

    return OnboardingShellScreen(
      currentStep: currentStep,
      totalSteps: totalSteps,
      onBack: currentStep == 0
          ? null
          : () {
              viewModel.previousStep();
            },
      onNext: () {
        if (currentStep < totalSteps - 1) {
          viewModel.nextStep();
        } else {
          viewModel.completeOnboarding(email: userEmail);
        }
      },
      nextButtonText:
          currentStep == totalSteps - 1 ? 'Get Started' : 'Continue',
      child: steps[currentStep],
    );
  }
}
