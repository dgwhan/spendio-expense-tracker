import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/core/widgets/shake_widget.dart';
import 'package:spend_io_app/features/home/presentation/screens/dashboard_screen.dart';
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
      onNext: () async {
        if (viewModel.canContinue()) {
          viewModel.setError(false);
          await viewModel.saveOnboarding(email: widget.userEmail);
          if (currentStep < totalSteps - 1) {
            viewModel.nextStep();
          } else {
            await viewModel.completeOnboarding(email: widget.userEmail);
            if (!context.mounted) return;
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const DashboardScreen(),
              ),
            );
          }
        } else {
          viewModel.setError(true);
          _shakeTrigger.add(true);
        }
      },
      nextButtonText:
          currentStep == totalSteps - 1 ? 'Get Started' : 'Continue',
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.98, end: 1.0).animate(animation),
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OnboardingViewModel>().loadOnboarding(email: widget.userEmail);
    });
  }
}
