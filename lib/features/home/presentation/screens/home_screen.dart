import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:spend_io_app/features/home/presentation/viewmodels/dashboard_viewmodel.dart';
import 'package:spend_io_app/features/account/presentation/viewmodels/account_viewmodel.dart';
import 'package:spend_io_app/features/home/presentation/widgets/app_header/app_header.dart';
import 'package:spend_io_app/features/home/presentation/widgets/balance_summary/balance_summary_card.dart';
import 'package:spend_io_app/features/home/presentation/widgets/financial_pulse/financial_pulse_section.dart';
import 'package:spend_io_app/features/home/presentation/widgets/monthly_budget/monthly_budget_progress.dart';
import 'package:spend_io_app/features/home/presentation/widgets/quick_actions/quick_actions_grid.dart';
import 'package:spend_io_app/features/home/presentation/widgets/recent_activity/recent_activity_section.dart';
import 'package:spend_io_app/features/home/presentation/widgets/savings_goal/savings_goal_card.dart';
import 'package:spend_io_app/features/home/presentation/widgets/spending_breakdown/spending_breakdown_section.dart';
import 'package:spend_io_app/features/home/data/models/dashboard_summary_model.dart';
import 'package:spend_io_app/features/transaction/presentation/screen/add_transaction_screen.dart';
import 'package:spend_io_app/features/transaction/presentation/viewmodels/transaction_viewmodel.dart';
import 'package:spend_io_app/features/wallet/domain/entities/saving_goal_entity.dart';
import 'package:spend_io_app/features/home/data/models/savings_goal_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _navigateToInsights(BuildContext context) {
    debugPrint('Navigation Action: Redirect to Insights Tab details.');
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final dashboardVM = context.watch<DashboardViewModel>();

    final displayName = authProvider.currentUser?.displayName ?? 'Guest';

    final summaryModel = DashboardSummaryModel(
      balance: dashboardVM.totalAssets,
      income: dashboardVM.totalAssets * 0.25 > 0
          ? dashboardVM.totalAssets * 0.25
          : 18000000,
      expense: dashboardVM.totalSpent,
      savings: dashboardVM.totalSaved,
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            final userEntity = authProvider.currentUser?.toEntity();
            if (userEntity != null) {
              final localId = userEntity.id ?? 1;
              final remoteUid = userEntity.id?.toString() ?? '';

              await dashboardVM.walletViewModel.initialize();

              if (context.mounted) {
                await context.read<AccountViewModel>().loadAccounts(
                      localId,
                      remoteUid,
                      forceRefresh: true,
                    );
              }
            }
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // 1. Header Section
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                sliver: SliverToBoxAdapter(
                  child: AppHeader(
                    displayName: displayName,
                    avatarUrl: '',
                    onProfileTap: () {},
                    onNotificationTap: () {},
                  ),
                ),
              ),

              // 2. Total Balance Card Section
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                sliver: SliverToBoxAdapter(
                  child: BalanceSummaryCard(
                    summary: summaryModel,
                  ),
                ),
              ),

              // 3. Quick Actions Grid Section
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                sliver: SliverToBoxAdapter(
                  child: QuickActionsGrid(
                    onTransactionTap: () {
                      final int currentUserId =
                          authProvider.currentUser?.toEntity().id ?? 1;
                      final accountVM = context.read<AccountViewModel>();

                      final String activeAccountId =
                          accountVM.accounts.isNotEmpty
                              ? accountVM.accounts.first.id
                              : '';

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AddTransactionScreen(
                            accountId: activeAccountId,
                            userId: currentUserId,
                            transactionVM: context.read<TransactionViewModel>(),
                          ),
                        ),
                      );
                    },
                    onBudgetTap: () =>
                        debugPrint('Quick Action: Budget clicked'),
                    onAnalyticsTap: () =>
                        debugPrint('Quick Action: Analytics clicked'),
                    onSavingGoalTap: () =>
                        debugPrint('Quick Action: Saving goal clicked'),
                  ),
                ),
              ),

              // 4. Spending Breakdown Section
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                sliver: SliverToBoxAdapter(
                  child: SpendingBreakdownSection(
                    weekData: dashboardVM.spendingBreakdownWeek,
                    monthData: dashboardVM.spendingBreakdownMonth,
                    yearData: dashboardVM.spendingBreakdownYear,
                    onViewDetailTap: () => _navigateToInsights(context),
                    onViewMoreTap: () => _navigateToInsights(context),
                  ),
                ),
              ),

              // 5. Financial Pulse Section
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                sliver: SliverToBoxAdapter(
                  child: FinancialPulseSection(
                    pulse: dashboardVM.financialPulse,
                  ),
                ),
              ),

              // 6. Savings Goals Section
              if (dashboardVM.savingsGoals.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  sliver: SliverToBoxAdapter(
                    child: SavingsGoalCard(
                      goals: dashboardVM.savingsGoals.map((g) {
                        return g.toSavingsGoalModel();
                      }).toList(),
                      onViewAllTap: () {},
                    ),
                  ),
                ),

              // 7. Monthly Budget Section
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                sliver: SliverToBoxAdapter(
                  child: MonthlyBudgetProgress(
                    budget: dashboardVM.monthlyBudget,
                  ),
                ),
              ),

              // 8. Recent Activity Section
              // 🌟 FIX DỨT ĐIỂM: Gỡ hoàn toàn 'if (dashboardVM.recentTransactions.isNotEmpty)'
              // để widget RecentActivitySection luôn hiển thị và tự xử lý trạng thái rỗng bên trong nó
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 40.0),
                sliver: SliverToBoxAdapter(
                  child: // Tại vị trí số 8 trong HomeScreen.dart sửa lại dòng này:
                      RecentActivitySection(
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

/// Extension mapping helper to convert domain entity to presentation model safely
extension on SavingGoalEntity {
  SavingsGoalModel toSavingsGoalModel() {
    final percent = progress;
    String status = 'ON TRACK';
    if (percent >= 0.8) {
      status = 'GREAT PROGRESS';
    } else if (percent < 0.2) {
      status = 'BEHIND';
    }
    return SavingsGoalModel(
      id: id,
      title: name,
      category: 'Finance',
      currentAmount: currentAmount,
      targetAmount: targetAmount,
      status: status,
      iconType: 'finance',
    );
  }
}
