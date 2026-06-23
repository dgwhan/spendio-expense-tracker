import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:spend_io_app/features/account/presentation/viewmodels/account_viewmodel.dart';
import 'package:spend_io_app/features/category/presentation/viewmodels/category_viewmodel.dart';
import 'package:spend_io_app/features/home/presentation/viewmodels/home_viewmodel.dart';
import 'package:spend_io_app/features/transaction/presentation/viewmodels/transaction_viewmodel.dart';
import 'package:spend_io_app/features/navigation/presentation/providers/navigation_provider.dart';
import 'package:spend_io_app/features/category/presentation/screens/category_list_screen.dart';

import 'package:spend_io_app/features/budget/presentation/viewmodels/monthly/budget_viewmodel.dart';
import 'package:spend_io_app/features/budget/presentation/viewmodels/monthly/budget_form_viewmodel.dart';
import 'package:spend_io_app/features/budget/presentation/screens/monthly/add_budget_screen.dart';
import 'package:spend_io_app/features/budget/presentation/screens/budget_detail_screen.dart';
import 'package:spend_io_app/features/saving_goal/presentation/screens/saving_goal_list_screen.dart';
import 'package:spend_io_app/features/transaction/presentation/screen/transaction_list_screen.dart';

import 'package:spend_io_app/features/home/presentation/widgets/app_header/app_header.dart';
import 'package:spend_io_app/features/home/presentation/widgets/balance_summary/balance_summary_card.dart';
import 'package:spend_io_app/features/home/presentation/widgets/quick_actions/quick_actions_grid.dart';
import 'package:spend_io_app/features/home/presentation/widgets/recent_activity/recent_activity_section.dart';
import 'package:spend_io_app/features/home/presentation/widgets/spending_breakdown/spending_breakdown_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _navigateToInsights(BuildContext context) {
    context.read<NavigationProvider>().changeTab(2);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final authProvider = context.watch<AuthProvider>();
    final dashboardVM = context.watch<HomeViewModel>();
    final txVM = context.watch<TransactionViewModel>();
    final budgetVM = context.watch<BudgetViewModel>();

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
              await context
                  .read<CategoryViewModel>()
                  .loadCategories(user.id ?? 1);
            }

            if (context.mounted) {
              await context.read<AccountViewModel>().loadAccounts(
                    user.id ?? 1,
                    user.id?.toString() ?? '',
                    forceRefresh: true,
                  );
            }

            if (context.mounted) {
              await context.read<TransactionViewModel>().loadAllTransactions();
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
                    summary: dashboardVM.getSummary(
                        context, txVM.state.transactions),
                  ),
                ),
              ),

              // ================= QUICK ACTIONS =================
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                sliver: SliverToBoxAdapter(
                  child: QuickActionsGrid(
                    onCreateBudgetTap: () {
                      final user = authProvider.currentUser;
                      if (user == null) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ChangeNotifierProvider<BudgetFormViewModel>(
                            create: (_) => BudgetFormViewModel(),
                            child: AddBudgetScreen(userId: user.id ?? 1),
                          ),
                        ),
                      );
                    },
                    onTransactionHistoryTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TransactionListScreen(),
                        ),
                      );
                    },
                    onManageSavingsTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SavingGoalListScreen(),
                        ),
                      );
                    },
                    onInsightsTap: () => _navigateToInsights(context),
                    onMonthlyBudgetTap: () {
                      final user = authProvider.currentUser;
                      if (user == null) return;
                      final currentBudgetProgress = budgetVM.currentBudget;

                      if (currentBudgetProgress == null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ChangeNotifierProvider<BudgetFormViewModel>(
                              create: (_) => BudgetFormViewModel(),
                              child: AddBudgetScreen(userId: user.id ?? 1),
                            ),
                          ),
                        );
                      } else {
                        final totalSpent = currentBudgetProgress.spent;
                        final totalBudget = currentBudgetProgress.budget.amount;
                        int daysLeft = currentBudgetProgress.budget.endDate
                            .difference(DateTime.now())
                            .inDays;
                        if (daysLeft < 0) daysLeft = 0;

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BudgetDetailScreen(
                              totalSpent: totalSpent,
                              totalBudget: totalBudget,
                              daysLeft: daysLeft,
                              userId: user.id ?? 1,
                            ),
                          ),
                        );
                      }
                    },
                    onCategoryManagementTap: () {
                      final user = authProvider.currentUser;
                      if (user == null) return;
                      final remoteUid =
                          fb.FirebaseAuth.instance.currentUser?.uid ?? '';
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CategoryListScreen(
                            userId: user.id ?? 1,
                            remoteUid: remoteUid,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // ================= SPENDING BREAKDOWN =================
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                sliver: SliverToBoxAdapter(
                  child: SpendingBreakdownSection(
                    weekData: dashboardVM.getSpendingBreakdownForPeriod(
                        context, 'Week'),
                    monthData: dashboardVM.getSpendingBreakdownForPeriod(
                        context, 'Month'),
                    yearData: dashboardVM.getSpendingBreakdownForPeriod(
                        context, 'Year'),
                    onViewDetailTap: () => _navigateToInsights(context),
                    onViewMoreTap: () => _navigateToInsights(context),
                  ),
                ),
              ),

              // // ================= FINANCIAL PULSE =================
              // SliverPadding(
              //   padding:
              //       const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              //   sliver: SliverToBoxAdapter(
              //     child: FinancialPulseSection(
              //       pulse: dashboardVM.getFinancialPulse(context),
              //     ),
              //   ),
              // ),

              // ================= RECENT ACTIVITY =================
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                sliver: SliverToBoxAdapter(
                  child: RecentActivitySection(
                    transactions: dashboardVM.getRecentTransactions(context),
                    onViewAllTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TransactionListScreen(),
                        ),
                      );
                    },
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
