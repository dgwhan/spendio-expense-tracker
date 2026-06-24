import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/utils/localization.dart';
import 'package:spend_io_app/core/widgets/common/app_screen_title.dart';
import 'package:spend_io_app/features/splash/presentation/screens/splash_screen.dart';
import 'package:spend_io_app/features/wallet/presentation/viewmodels/wallet_viewmodel.dart';
import 'package:spend_io_app/features/category/presentation/viewmodels/category_viewmodel.dart';
import 'package:spend_io_app/features/transaction/presentation/viewmodels/transaction_viewmodel.dart';
import 'package:spend_io_app/features/budget/presentation/viewmodels/monthly/budget_viewmodel.dart';
import 'package:spend_io_app/features/budget/presentation/viewmodels/category/budget_category_viewmodel.dart';
import 'package:spend_io_app/features/saving_goal/presentation/viewmodels/saving_goal_list_viewmodel.dart';
import 'package:spend_io_app/features/insight/presentation/viewmodels/insight_viewmodel.dart';
import 'package:spend_io_app/features/onboarding/presentation/viewmodels/onboarding_viewmodel.dart';
import '../viewmodels/profile_viewmodel.dart';
import '../widgets/profile_loading_overlay.dart';
import 'edit_profile_screen.dart';

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
    final isDark = viewModel.isDarkMode;

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

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          SafeArea(
            top: true,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverAppBar(
                  pinned: true,
                  floating: false,
                  elevation: 0,
                  centerTitle: true,
                  backgroundColor: backgroundColor,
                  toolbarHeight: 48,
                  title: AppScreenTitle(
                    title: AppLocalizations.translate('profile'),
                    isCenter: true,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
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
                                title: Text(
                                    AppLocalizations.translate('edit_profile'),
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: textPrimary)),
                                trailing: Icon(Icons.chevron_right_rounded,
                                    color: textSecondary),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const EditProfileScreen(),
                                    ),
                                  );
                                },
                              ),
                              Divider(
                                  color: dividerColor, height: 1, indent: 56),
                              ListTile(
                                leading: Icon(Icons.translate_rounded,
                                    color: textPrimary.withValues(alpha: 0.5)),
                                title: Text(
                                    AppLocalizations.translate('language'),
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: textPrimary.withValues(alpha: 0.5))),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                        'English',
                                        style: TextStyle(
                                            color: textSecondary.withValues(alpha: 0.5),
                                            fontSize: 14)),
                                    const SizedBox(width: 4),
                                    Icon(Icons.lock_outline_rounded,
                                        color: textSecondary.withValues(alpha: 0.5),
                                        size: 16),
                                  ],
                                ),
                                onTap: null, // Khóa đổi ngôn ngữ
                              ),
                              Divider(
                                  color: dividerColor, height: 1, indent: 56),
                              ListTile(
                                leading: Icon(Icons.dark_mode_outlined,
                                    color: textPrimary),
                                title: Text(
                                    AppLocalizations.translate('dark_mode'),
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: textPrimary)),
                                trailing: Switch.adaptive(
                                  value: isDark,
                                  onChanged: (value) =>
                                      viewModel.toggleTheme(value),
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
                              backgroundColor:
                                  AppColors.error.withValues(alpha: 0.1),
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
                                    // Clear providers trước khi điều hướng Login để tránh dính cache trên RAM
                                    context.read<WalletViewModel>().updateUser(null);
                                    context.read<CategoryViewModel>().clear();
                                    context.read<TransactionViewModel>().clearTransactions();
                                    context.read<BudgetViewModel>().clear();
                                    context.read<BudgetCategoryViewModel>().clear();
                                    context.read<SavingGoalListViewModel>().clearGoals();
                                    context.read<InsightViewModel>().clear();
                                    context.read<OnboardingViewModel>().clear();

                                    final success = await context
                                        .read<ProfileViewModel>()
                                        .handleLogout();
                                    if (success && context.mounted) {
                                      Navigator.of(context, rootNavigator: true)
                                          .pushAndRemoveUntil(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const SplashScreen(),
                                        ),
                                        (route) => false,
                                      );
                                    }
                                  },
                            icon: const Icon(Icons.logout_rounded, size: 20),
                            label: Text(
                              AppLocalizations.translate('sign_out'),
                              style: const TextStyle(
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
              ],
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
