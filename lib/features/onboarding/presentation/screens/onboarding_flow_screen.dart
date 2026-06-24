import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/features/navigation/presentation/screens/navigation_entry.dart';
import 'package:spend_io_app/features/onboarding/presentation/screens/onboarding_shell_screen.dart';
import 'package:spend_io_app/features/onboarding/presentation/screens/phases/balance_phase_screen.dart';
import 'package:spend_io_app/features/onboarding/presentation/screens/phases/currency_phase_screen.dart';
import 'package:spend_io_app/features/onboarding/presentation/screens/phases/goals_phase_screen.dart';
import 'package:spend_io_app/features/onboarding/presentation/screens/phases/identity_phase_screen.dart';
import 'package:spend_io_app/features/onboarding/presentation/screens/phases/profession_phase_screen.dart';
import 'package:spend_io_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/features/profile/presentation/viewmodels/profile_viewmodel.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final onboardingVM = context.read<OnboardingViewModel>();
      await onboardingVM.loadOnboarding(email: widget.userEmail);
    });
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
          if (currentStep == 4) {
            final balance = viewModel.initialBalance ?? 0.0;
            if (balance > 999999999) {
              viewModel.setError(true);
              viewModel.triggerShake(); // Kích hoạt hiệu ứng qua ViewModel
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
            viewModel.nextStep();
          } else {
            FocusScope.of(context).unfocus();
            await viewModel.completeOnboarding(email: widget.userEmail);

            if (!context.mounted) return;
            await context.read<ProfileViewModel>().changeLanguage('en');

            if (!context.mounted) return;
            await context.read<AuthProvider>().reloadUser();

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
          viewModel
              .triggerShake(); // Kích hoạt Stream phát tín hiệu lắc khẽ cho các card con lắng nghe
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
          child: steps[
              currentStep], // Sạch sẽ, không bọc cấu trúc ShakeWidget toàn cục ở đây nữa
        ),
      ),
    );
  }
}
