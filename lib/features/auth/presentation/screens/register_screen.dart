import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_textfield.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> register() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.register(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    if (!mounted) return;

    if (success) {

      // TODO: Replace onboarding destination route index 

      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration successful!'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration failed'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Circular Back Arrow Button Asset Layout
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEEFF3), 
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Title Headline Matrix
              const Text(
                'Register Now',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 24),

              // Form Component Stack Fields
              AuthTextField(
                controller: emailController,
                hintText: 'Email address',
                prefixIcon: Icons.email_outlined,
              ),

              const SizedBox(height: 16),

              AuthTextField(
                controller: passwordController,
                hintText: 'Password',
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: true,
              ),

              const SizedBox(height: 16),

              AuthTextField(
                controller: confirmPasswordController,
                hintText: 'Confirm password',
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: true,
              ),

              const SizedBox(height: 28),

              // High Contrast CTA Button Implementation
              PrimaryButton(
                title: authProvider.isLoading ? 'Processing...' : 'Sign Up',
                onPressed: authProvider.isLoading ? () {} : register,
              ),

              const SizedBox(height: 24),

              // Inline Interactive Redirection Footer Link Elements
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context), 
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                        fontFamily: 'sans-serif',
                      ),
                      children: [
                        const TextSpan(text: 'Already have an account? '),
                        TextSpan(
                          text: 'Sign in',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
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