import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/core/widgets/shake_widget.dart';
import 'package:spend_io_app/features/navigation/presentation/screens/navigation_entry.dart';
import 'package:spend_io_app/features/onboarding/presentation/screens/onboarding_shell_screen.dart';
import 'package:spend_io_app/features/onboarding/presentation/screens/phases/balance_phase_screen.dart';
import 'package:spend_io_app/features/onboarding/presentation/screens/phases/currency_phase_screen.dart';
import 'package:spend_io_app/features/onboarding/presentation/screens/phases/goals_phase_screen.dart';
import 'package:spend_io_app/features/onboarding/presentation/screens/phases/identity_phase_screen.dart';
import 'package:spend_io_app/features/onboarding/presentation/screens/phases/profession_phase_screen.dart';
import 'package:spend_io_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final onboardingVM = context.read<OnboardingViewModel>();
      await onboardingVM.loadOnboarding(email: widget.userEmail);

      debugPrint('[ONBOARDING] Flow STARTED for user: ${widget.userEmail}');
      debugPrint('[ONBOARDING DATA INITIAL] '
          'displayName: ${onboardingVM.displayName}, '
          'occupation: ${onboardingVM.occupation}, '
          'goals: ${onboardingVM.goals}, '
          'currencyCode: ${onboardingVM.currencyCode}, '
          'initialBalance: ${onboardingVM.initialBalance}');
    });
  }

  @override
  void dispose() {
    _shakeTrigger.close();
    super.dispose();
  }

  String _getStepName(int step) {
    switch (step) {
      case 0:
        return 'Identity';
      case 1:
        return 'Profession';
      case 2:
        return 'Goals';
      case 3:
        return 'Currency';
      case 4:
        return 'Balance';
      default:
        return 'Unknown';
    }
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
              debugPrint(
                  '[ONBOARDING] User click BACK: Step $currentStep -> ${currentStep - 1}');
              viewModel.setError(false);
              viewModel.previousStep();
            },
      onNext: () async {
        debugPrint(
            '[ONBOARDING INTERACT] User triggered NEXT at step $currentStep (${_getStepName(currentStep)})');
        debugPrint('[ONBOARDING CURRENT STATE] '
            'displayName: ${viewModel.displayName}, '
            'occupation: ${viewModel.occupation}, '
            'goals: ${viewModel.goals}, '
            'currencyCode: ${viewModel.currencyCode}, '
            'initialBalance: ${viewModel.initialBalance}');

        if (viewModel.canContinue()) {
          if (currentStep == 4) {
            final balance = viewModel.initialBalance ?? 0.0;
            if (balance > 999999999) {
              viewModel.setError(true);
              _shakeTrigger.add(true);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Amount cannot exceed 999.999.999'),
                  backgroundColor: AppColors.error,
                ),
              );
              return;
            }
          }
          viewModel.setError(false);

          if (currentStep < totalSteps - 1) {
            debugPrint(
                '[ONBOARDING] Step $currentStep SUCCESS -> Moving to step ${currentStep + 1} (${_getStepName(currentStep + 1)})');
            viewModel.nextStep();
          } else {
            FocusScope.of(context).unfocus();
            debugPrint(
                '[ONBOARDING] User clicked GET STARTED at final step. Submitting to local DB...');

            await viewModel.completeOnboarding(email: widget.userEmail);

            if (!context.mounted) return;
            await context.read<AuthProvider>().reloadUser();

            debugPrint(
                '[ONBOARDING SUCCESS] PROFILE SAVED COMPLETE FOR ${widget.userEmail}');
            debugPrint('[ONBOARDING FINAL DATA GATHERED] '
                'displayName: ${viewModel.displayName}, '
                'occupation: ${viewModel.occupation}, '
                'goals: ${viewModel.goals}, '
                'currencyCode: ${viewModel.currencyCode}, '
                'initialBalance: ${viewModel.initialBalance}');

            if (!context.mounted) return;
            await Future.delayed(const Duration(milliseconds: 150));

            if (!context.mounted) return;
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const NavigationEntry(),
              ),
            );
          }
        } else {
          viewModel.setError(true);
          _shakeTrigger.add(true);
          debugPrint(
              '[ONBOARDING VALIDATION FAILED] at step $currentStep (${_getStepName(currentStep)}). Triggering Shake animation.');
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
}
