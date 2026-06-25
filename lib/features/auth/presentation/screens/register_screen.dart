import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_strings.dart';
import 'package:spend_io_app/core/dialogs/app_dialogs.dart';
import 'package:spend_io_app/core/theme/text_styles.dart';
import 'package:spend_io_app/core/widgets/app_header.dart';
import 'package:spend_io_app/core/widgets/button/app_button.dart';
import 'package:spend_io_app/core/widgets/button/app_text_button.dart';

import 'package:spend_io_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:spend_io_app/features/auth/presentation/screens/login_screen.dart';
import 'package:spend_io_app/features/auth/presentation/viewmodels/register_form_viewmodel.dart';
import 'package:spend_io_app/features/auth/presentation/widgets/register_fields.dart';
import 'package:spend_io_app/features/onboarding/presentation/screens/onboarding_flow_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RegisterFormViewModel>().clearForm();
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> register() async {
    final authProvider = context.read<AuthProvider>();

    // Chặn double-click và multiple submit
    if (authProvider.isLoading) {
      return;
    }

    final emailText = emailController.text.trim();
    final passwordText = passwordController.text.trim();
    final confirmPasswordText = confirmPasswordController.text.trim();

    // 1. Kiểm tra tất cả field trước khi submit
    // Field rỗng => hiện AppDialogs.warning
    if (emailText.isEmpty || passwordText.isEmpty || confirmPasswordText.isEmpty) {
      await AppDialogs.warning(
        context: context,
        title: AppStrings.warningTitle,
        content: AppStrings.errorEmptyFields,
      );
      return;
    }

    // Email sai format => AppDialogs.warning
    final emailRegex = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    );
    if (!emailRegex.hasMatch(emailText)) {
      await AppDialogs.warning(
        context: context,
        title: AppStrings.warningTitle,
        content: AppStrings.errorInvalidEmail,
      );
      return;
    }

    // Password không đạt yêu cầu => AppDialogs.warning
    if (passwordText.length < 6) {
      await AppDialogs.warning(
        context: context,
        title: AppStrings.warningTitle,
        content: AppStrings.errorPasswordLength,
      );
      return;
    }

    // Confirm password không khớp => AppDialogs.warning
    if (passwordText != confirmPasswordText) {
      await AppDialogs.warning(
        context: context,
        title: AppStrings.warningTitle,
        content: AppStrings.errorPasswordMismatch,
      );
      return;
    }

    final formVM = context.read<RegisterFormViewModel>();

    if (formVM.isEmailChecking) {
      return;
    }

    // Email đã tồn tại => hiện AppDialogs.emailExists
    if (formVM.isEmailTaken) {
      await AppDialogs.emailExists(context);
      return;
    }

    // 2. Thực hiện đăng ký (gọi usecase/repository qua authProvider)
    final String? errorMessage = await authProvider.register(
      email: emailText,
      password: passwordText,
    );

    if (!mounted) {
      return;
    }

    if (errorMessage == null) {
      // Thành công => AppDialogs.success
      await AppDialogs.success(
        context: context,
        title: AppStrings.successTitle,
        content: AppStrings.successRegister,
        onConfirm: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => OnboardingFlowScreen(userEmail: emailText),
            ),
            (route) => false,
          );
        },
      );
    } else {
      // Thất bại => AppDialogs.error hoặc networkError
      if (errorMessage.contains('email-already-in-use') ||
          errorMessage.contains('exists')) {
        await AppDialogs.emailExists(context);
      } else if (errorMessage.contains('network') ||
          errorMessage.contains('SocketException')) {
        await AppDialogs.networkError(
          context: context,
          title: AppStrings.networkErrorTitle,
          content: AppStrings.networkErrorMessage,
        );
      } else {
        await AppDialogs.error(
          context: context,
          title: AppStrings.errorTitle,
          content: errorMessage,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final formVM = context.watch<RegisterFormViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppHeader(
        title: '',
        showBack: true,
        onBack: () => Navigator.pop(context),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Register Now',
                  style: TextStyles.heading1(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 24),
                RegisterFields(
                  formVM: formVM,
                  emailController: emailController,
                  passwordController: passwordController,
                  confirmPasswordController: confirmPasswordController,
                  onFieldSubmitted: () {
                    FocusScope.of(context).unfocus();
                  },
                ),
                const SizedBox(height: 32),
                AppButton(
                  title: 'Sign Up',
                  isLoading: authProvider.isLoading,
                  variant: AppButtonVariant.primary,
                  onPressed: register,
                ),
                const SizedBox(height: 24),
                _buildFooter(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: TextStyles.bodyLarge(color: AppColors.textSecondaryLight),
        ),
        AppTextButton(
          text: 'Sign in',
          fontWeight: FontWeight.w600,
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          },
        ),
      ],
    );
  }
}
