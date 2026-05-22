import 'package:flutter/material.dart';

import '../../../../core/widgets/primary_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

/// onboarding page controller
class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  int currentPage = 0;

  void nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: PageView(
          controller: _pageController,

          onPageChanged: (value) {
            setState(() {
              currentPage = value;
            });
          },

          children: [
            buildIntroPage(),

            buildAuthPage(),
          ],
        ),
      ),
    );
  }

  /// first onboarding page
  Widget buildIntroPage() {
    return Padding(
      padding: const EdgeInsets.all(24),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Spacer(),

          const Text(
            'Xin chào 👋',

            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Spend IO giúp bạn quản lý chi tiêu thông minh, theo dõi tài chính và xây dựng thói quen tiết kiệm hiệu quả.',

            style: TextStyle(
              fontSize: 18,
              height: 1.6,
              color: Color(0xFF4B5563),
            ),
          ),

          const Spacer(),

          PrimaryButton(
            title: 'Continue',

            onPressed: nextPage,
          ),
        ],
      ),
    );
  }

  /// auth selection page
  Widget buildAuthPage() {
    return Padding(
      padding: const EdgeInsets.all(24),

      child: Column(
        children: [
          const Spacer(),

          Container(
            width: 120,
            height: 120,

            decoration: BoxDecoration(
              color: const Color(0xFF5B5FEF).withOpacity(0.1),
              shape: BoxShape.circle,
            ),

            child: const Icon(
              Icons.account_balance_wallet_rounded,
              size: 60,
              color: Color(0xFF5B5FEF),
            ),
          ),

          const SizedBox(height: 32),

          const Text(
            'Bắt đầu ngay',

            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'Đăng nhập hoặc tạo tài khoản để tiếp tục sử dụng Spend IO.',

            textAlign: TextAlign.center,

            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: Color(0xFF6B7280),
            ),
          ),

          const Spacer(),

          PrimaryButton(
            title: 'Login',

            onPressed: () {},
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 58,

            child: OutlinedButton(
              onPressed: () {},

              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF5B5FEF),

                side: const BorderSide(
                  color: Color(0xFF5B5FEF),
                ),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),

              child: const Text(
                'Sign Up',

                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}