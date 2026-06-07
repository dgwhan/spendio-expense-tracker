import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/features/navigation/presentation/screens/navigation_entry.dart';
import 'package:spend_io_app/features/auth/presentation/screens/login_screen.dart';
import 'package:spend_io_app/features/onboarding/presentation/screens/onboarding_flow_screen.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/theme/text_styles.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_textfield.dart';
import '../viewmodels/register_form_viewmodel.dart';
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

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> register() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final emailText = emailController.text.trim();

    final success = await authProvider.register(
      email: emailText,
      password: passwordController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const NavigationEntry(),
        ),
        (route) => false,
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => OnboardingFlowScreen(
            userEmail: emailText,
          ),
        ),
        (route) => false,
      );
    } else {
      await AppDialogs.emailExists(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final formVM = context.watch<RegisterFormViewModel>();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // BACK BUTTON
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
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
                  ),

                  const SizedBox(height: 28),

                  // TITLE
                  Text(
                    'Register Now',
                    style: TextStyles.heading1(
                      color: AppColors.textPrimaryLight,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ================= EMAIL =================
                  AuthTextField(
                    controller: emailController,
                    hintText: 'Email address',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    onChanged: (value) {
                      formVM.onEmailChanged(value);
                    },
                  ),

                  const SizedBox(height: 6),

                  if (formVM.isEmailChecking)
                    const Text('Checking email...')
                  else if (!formVM.isEmailValidFormat)
                    const Text(
                      'Invalid email format',
                      style: TextStyle(color: Colors.red),
                    )
                  else if (formVM.isEmailTaken)
                    const Text(
                      'Email already exists',
                      style: TextStyle(color: Colors.red),
                    )
                  else if (formVM.isEmailValidFormat && !formVM.isEmailTaken)
                    const Text(
                      'Email available',
                      style: TextStyle(color: Colors.green),
                    ),

                  const SizedBox(height: 16),

                  // ================= PASSWORD =================
                  AuthTextField(
                    controller: passwordController,
                    hintText: 'Password',
                    prefixIcon: Icons.lock_outline_rounded,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.next,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textMutedLight,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    onChanged: (value) {
                      formVM.onPasswordChanged(value);
                    },
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'Strength: ${formVM.passwordStrength}',
                    style: TextStyle(
                      color: formVM.passwordStrength == 'Strong'
                          ? Colors.green
                          : formVM.passwordStrength == 'Medium'
                              ? Colors.orange
                              : Colors.red,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ================= CONFIRM PASSWORD =================
                  AuthTextField(
                    controller: confirmPasswordController,
                    hintText: 'Confirm password',
                    prefixIcon: Icons.lock_outline_rounded,
                    obscureText: _obscureConfirmPassword,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textMutedLight,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    onChanged: (value) {
                      formVM.onConfirmPasswordChanged(value);
                    },
                  ),

                  const SizedBox(height: 6),

                  if (formVM.passwordMatchMessage != null)
                    Text(
                      formVM.passwordMatchMessage!,
                      style:
                          const TextStyle(color: AppColors.error, fontSize: 12),
                    )
                  else if (formVM.isPasswordMatch)
                    const Text(
                      "Passwords match",
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                      ),
                    ),
                  const SizedBox(height: 28),

                  // ================= BUTTON =================
                  PrimaryButton(
                    title: authProvider.isLoading ? 'Processing...' : 'Sign Up',
                    onPressed: (!formVM.isFormValid || authProvider.isLoading)
                        ? null
                        : () async => await register(),
                  ),

                  const SizedBox(height: 24),

                  // FOOTER
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ));
                      },
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Already have an account? ',
                              style: TextStyles.bodyLarge(
                                color: AppColors.textSecondaryLight,
                              ),
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
