import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/core/widgets/shake_widget.dart';
import 'package:spend_io_app/features/onboarding/presentation/screens/onboarding_shell_screen.dart';
import 'package:spend_io_app/features/onboarding/presentation/screens/phases/balance_phase_screen.dart';
import 'package:spend_io_app/features/onboarding/presentation/screens/phases/currency_phase_screen.dart';
import 'package:spend_io_app/features/onboarding/presentation/screens/phases/goals_phase_screen.dart';
import 'package:spend_io_app/features/onboarding/presentation/screens/phases/identity_phase_screen.dart';
import 'package:spend_io_app/features/onboarding/presentation/screens/phases/profession_phase_screen.dart';
import '../viewmodels/onboarding_viewmodel.dart';

class OnboardingFlowScreen extends StatefulWidget {
  final String userEmail;

  const OnboardingFlowScreen({
    super.key,
    required this.userEmail,
  });

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  final StreamController<bool> _shakeTrigger =
      StreamController<bool>.broadcast();

  @override
  void dispose() {
    _shakeTrigger.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<OnboardingViewModel>();
    final int currentStep = viewModel.currentStep;
    const int totalSteps = 5;

    final List<Widget> steps = [
      IdentityPhaseScreen(userEmail: widget.userEmail),
      const ProfessionPhaseScreen(),
      const GoalsPhaseScreen(),
      const CurrencyPhaseScreen(),
      const BalancePhaseScreen()
    ];

    return OnboardingShellScreen(
      currentStep: currentStep,
      totalSteps: totalSteps,
      onBack: currentStep == 0
          ? null
          : () {
              viewModel.setError(false);
              viewModel.previousStep();
            },
      onNext: () {
        if (viewModel.canContinue()) {
          viewModel.setError(false);
          if (currentStep < totalSteps - 1) {
            viewModel.nextStep();
          } else {
            viewModel.completeOnboarding(email: widget.userEmail);
          }
        } else {
          viewModel.setError(true);
          _shakeTrigger.add(true);
        }
      },
      nextButtonText:
          currentStep == totalSteps - 1 ? 'Get Started' : 'Continue',
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        transitionBuilder: (Widget child, Animation<double> animation) {
          final inAnimation = Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic));

          return SlideTransition(
            position: inAnimation,
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        child: Container(
          key: ValueKey<int>(currentStep),
          child: ShakeWidget(
            triggerStream: _shakeTrigger.stream,
            child: steps[currentStep],
          ),
        ),
      ),
    );
  }
}
