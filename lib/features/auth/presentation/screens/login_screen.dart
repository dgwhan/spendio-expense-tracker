import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/primary_button.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_textfield.dart';
import '../viewmodels/login_form_viewmodel.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _rememberMe = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.login(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Login successful!' : 'Invalid credentials',
        ),
        backgroundColor:
            success ? AppColors.success : AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final loginVM = context.watch<LoginFormViewModel>();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
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
                    color: AppColors.textPrimaryLight,
                    size: 20,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // TITLE
              Text(
                'Welcome back',
                style: TextStyles.heading1(
                  color: AppColors.textPrimaryLight,
                ),
              ),

              const SizedBox(height: 32),

              // ================= EMAIL =================
              AuthTextField(
                controller: emailController,
                hintText: 'Email address',
                prefixIcon: Icons.email_outlined,
                onChanged: (value) {
                  loginVM.onEmailChanged(value);
                },
              ),

              const SizedBox(height: 6),

              if (loginVM.isEmailEmpty)
                const Text(
                  'Email is required',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                )
              else if (!loginVM.isEmailValidFormat)
                const Text(
                  'Invalid email format',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),

              const SizedBox(height: 16),

              // ================= PASSWORD =================
              AuthTextField(
                controller: passwordController,
                hintText: 'Password',
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: true,
                onChanged: (value) {
                  loginVM.onPasswordChanged(value);
                },
              ),

              const SizedBox(height: 6),

              if (loginVM.isPasswordEmpty)
                const Text(
                  'Password is required',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                )
              else if (passwordController.text.length < 6)
                const Text(
                  'Minimum 6 characters',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),

              const SizedBox(height: 20),

              // ================= REMEMBER ME =================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: Checkbox(
                          value: _rememberMe,
                          activeColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _rememberMe = value ?? false;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Remember me',
                        style: TextStyles.bodyMedium(
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                    ],
                  ),

                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      'Forgot password?',
                      style: TextStyles.bodyMedium(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // ================= BUTTON =================
              PrimaryButton(
                title: authProvider.isLoading
                    ? 'Processing...'
                    : 'Sign In',
                onPressed: (!loginVM.isFormValid ||
                        authProvider.isLoading)
                    ? null
                    : () async => await login(),
              ),

              const SizedBox(height: 24),

              // ================= FOOTER =================
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RegisterScreen(),
                      ),
                    );
                  },
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Don’t have an account? ',
                          style: TextStyles.bodyMedium(
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                        TextSpan(
                          text: 'Register',
                          style: TextStyles.bodyMedium(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}