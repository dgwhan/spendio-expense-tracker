import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/features/auth/presentation/screens/login_screen.dart';
import 'package:spend_io_app/features/onboarding/presentation/screens/onboarding_flow_screen.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/theme/text_styles.dart';
import '../providers/auth_provider.dart';
import '../viewmodels/register_form_viewmodel.dart';
import '../widgets/register_fields.dart';
import '../../../../core/dialogs/app_dialogs.dart';

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
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final formVM = context.read<RegisterFormViewModel>();

    if (formVM.isEmailChecking) {
      return;
    }

    if (formVM.isEmailTaken) {
      await AppDialogs.emailExists(context);
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final emailText = emailController.text.trim();

    final String? errorMessage = await authProvider.register(
      email: emailText,
      password: passwordController.text.trim(),
    );

    if (!mounted) {
      return;
    }

    if (errorMessage == null) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => OnboardingFlowScreen(userEmail: emailText),
        ),
        (route) => false,
      );
    } else {
      if (errorMessage.contains('email-already-in-use') ||
          errorMessage.contains('exists')) {
        await AppDialogs.emailExists(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage.isNotEmpty
                ? errorMessage
                : 'Registration failed. Please try again.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final formVM = context.watch<RegisterFormViewModel>();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBackButton(context),
                const SizedBox(height: 28),
                Text(
                  'Register Now',
                  style: TextStyles.heading1(color: AppColors.textPrimaryLight),
                ),
                const SizedBox(height: 24),

                // Inject module ô nhập liệu register đã tách rời
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
                  title: authProvider.isLoading ? 'Processing...' : 'Sign Up',
                  onPressed: (!formVM.isFormValid || authProvider.isLoading)
                      ? null
                      : register,
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

  Widget _buildBackButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        height: 40,
        width: 40,
        decoration: const BoxDecoration(
          color: AppColors.surfaceSecondaryLight,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.arrow_back,
          size: 20,
          color: AppColors.textPrimaryLight,
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        },
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Already have an account? ',
                style:
                    TextStyles.bodyLarge(color: AppColors.textSecondaryLight),
              ),
              TextSpan(
                text: 'Sign in',
                style: TextStyles.bodyLarge(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
