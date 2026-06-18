import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/features/splash/presentation/screens/splash_screen.dart';
import '../viewmodels/profile_viewmodel.dart';
import '../widgets/profile_tile.dart';
import '../widgets/profile_loading_overlay.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileViewModel>().loadCurrentUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProfileViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final surfaceColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final dividerColor =
        isDark ? AppColors.dividerDark : AppColors.dividerLight;
    final borderBoxColor =
        isDark ? AppColors.borderDark : AppColors.borderLight;

    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    final textMuted =
        isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
    final creditCardColor =
        isDark ? AppColors.creditCardDark : AppColors.creditCardLight;
    final creditCardBg =
        isDark ? AppColors.creditCardBgDark : AppColors.creditCardBgLight;
    final cashColor = isDark ? AppColors.cashDark : AppColors.cashLight;
    final cashBg = isDark ? AppColors.cashBgDark : AppColors.cashBgLight;
    final bankColor = isDark ? AppColors.bankDark : AppColors.bankLight;
    final bankBg = isDark ? AppColors.bankBgDark : AppColors.bankBgLight;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold, color: textPrimary),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.transparent,
        iconTheme: IconThemeData(color: textPrimary),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor:
                              AppColors.primary.withValues(alpha: 0.12),
                          child: const Icon(
                            Icons.person_rounded,
                            size: 56,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          viewModel.user?.displayName ?? 'Guest User',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          viewModel.user?.email ?? 'No email bound',
                          style: TextStyle(
                            fontSize: 14,
                            color: textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: borderBoxColor),
                    ),
                    child: Column(
                      children: [
                        ProfileTile(
                          icon: Icons.flag_rounded,
                          iconColor: creditCardColor,
                          iconBgColor: creditCardBg,
                          title: 'Financial Goal',
                          value: viewModel.user?.financialGoal ?? 'Not set',
                          textPrimaryColor: textPrimary,
                          textSecondaryColor: textSecondary,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Divider(color: dividerColor),
                        ),
                        ProfileTile(
                          icon: Icons.currency_exchange_rounded,
                          iconColor: cashColor,
                          iconBgColor: cashBg,
                          title: 'Currency',
                          value: viewModel.user?.currency ?? 'USD',
                          textPrimaryColor: textPrimary,
                          textSecondaryColor: textSecondary,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Divider(color: dividerColor),
                        ),
                        ProfileTile(
                          icon: Icons.work_rounded,
                          iconColor: bankColor,
                          iconBgColor: bankBg,
                          title: 'Occupation',
                          value: viewModel.user?.occupation ?? 'Unknown',
                          textPrimaryColor: textPrimary,
                          textSecondaryColor: textSecondary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'General Settings',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: textMuted,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: borderBoxColor),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.person_outline_rounded,
                              color: textPrimary),
                          title: Text('Edit Profile',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: textPrimary)),
                          trailing: Icon(Icons.chevron_right_rounded,
                              color: textSecondary),
                          onTap: () {},
                        ),
                        Divider(height: 1, indent: 56, color: dividerColor),
                        ListTile(
                          leading: Icon(Icons.lock_outline_rounded,
                              color: textPrimary),
                          title: Text('Security & PIN',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: textPrimary)),
                          trailing: Icon(Icons.chevron_right_rounded,
                              color: textSecondary),
                          onTap: () {},
                        ),
                        Divider(height: 1, indent: 56, color: dividerColor),
                        ListTile(
                          leading: Icon(Icons.dark_mode_outlined,
                              color: textPrimary),
                          title: Text('Dark Mode',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: textPrimary)),
                          trailing: Switch.adaptive(
                            value: isDark,
                            onChanged: (_) {},
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error.withValues(alpha: 0.1),
                        foregroundColor: AppColors.error,
                        elevation: 0,
                        shadowColor: AppColors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: AppColors.error.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                      ),
                      onPressed: viewModel.isLoading
                          ? null
                          : () async {
                              final success = await context
                                  .read<ProfileViewModel>()
                                  .handleLogout();
                              if (success && context.mounted) {
                                Navigator.of(context, rootNavigator: true)
                                    .pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) => const SplashScreen(),
                                  ),
                                  (route) => false,
                                );
                              }
                            },
                      icon: const Icon(Icons.logout_rounded, size: 20),
                      label: const Text(
                        'Sign Out',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (viewModel.isLoading)
            ProfileLoadingOverlay(
              isDark: isDark,
              surfaceColor: surfaceColor,
              borderBoxColor: borderBoxColor,
            ),
        ],
      ),
    );
  }
}
