import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:spend_io_app/features/account/presentation/viewmodels/account_viewmodel.dart';
import 'package:spend_io_app/features/home/presentation/viewmodels/home_viewmodel.dart';

import 'package:spend_io_app/features/home/presentation/widgets/app_header/app_header.dart';
import 'package:spend_io_app/features/home/presentation/widgets/balance_summary/balance_summary_card.dart';
import 'package:spend_io_app/features/home/presentation/widgets/financial_pulse/financial_pulse_section.dart';
import 'package:spend_io_app/features/home/presentation/widgets/quick_actions/quick_actions_grid.dart';
import 'package:spend_io_app/features/home/presentation/widgets/recent_activity/recent_activity_section.dart';
import 'package:spend_io_app/features/home/presentation/widgets/spending_breakdown/spending_breakdown_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _navigateToInsights(BuildContext context) {}

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final authProvider = context.watch<AuthProvider>();
    final dashboardVM = context.watch<HomeViewModel>();

    final displayName = authProvider.currentUser?.displayName ?? 'Guest';

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            final user = authProvider.currentUser?.toEntity();
            if (user == null) return;

            await dashboardVM.walletViewModel.initialize();

            if (context.mounted) {
              await context.read<AccountViewModel>().loadAccounts(
                    user.id ?? 1,
                    user.id?.toString() ?? '',
                    forceRefresh: true,
                  );
            }
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ================= HEADER =================
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                sliver: SliverToBoxAdapter(
                  child: AppHeader(
                    displayName: displayName,
                    avatarUrl: '',
                    onProfileTap: () {},
                    onNotificationTap: () {},
                  ),
                ),
              ),

              // ================= BALANCE =================
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                sliver: SliverToBoxAdapter(
                  child: BalanceSummaryCard(
                    summary: dashboardVM.summary,
                  ),
                ),
              ),

              // ================= QUICK ACTIONS =================
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                sliver: SliverToBoxAdapter(
                  child: QuickActionsGrid(
                    onCreateBudgetTap: () {},
                    onTransactionHistoryTap: () {},
                    onManageSavingsTap: () {},
                    onInsightsTap: () => _navigateToInsights(context),
                    onMonthlyBudgetTap: () {},
                    onCategoryManagementTap: () {},
                  ),
                ),
              ),

              // ================= SPENDING BREAKDOWN =================
              // SliverPadding(
              //   padding:
              //       const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              //   sliver: SliverToBoxAdapter(
              //     child: SpendingBreakdownSection(
              //       data: dashboardVM.getSpendingBreakdown(context),
              //       onViewDetailTap: () => _navigateToInsights(context),
              //       onViewMoreTap: () => _navigateToInsights(context),
              //     ),
              //   ),
              // ),

              // ================= FINANCIAL PULSE =================
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                sliver: SliverToBoxAdapter(
                  child: FinancialPulseSection(
                    pulse: dashboardVM.getFinancialPulse(context),
                  ),
                ),
              ),

              // ================= RECENT ACTIVITY =================
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                sliver: SliverToBoxAdapter(
                  child: RecentActivitySection(
                    transactions: dashboardVM.getRecentTransactions(context),
                    onViewAllTap: () {},
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
