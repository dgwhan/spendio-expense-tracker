import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/features/dashboard/presentation/widgets/app_header/app_header.dart';
import 'package:spend_io_app/features/dashboard/presentation/widgets/balance_summary/balance_summary_card.dart';
import 'package:spend_io_app/features/dashboard/datasource/mock/dashboard_mock_data.dart';
import 'package:spend_io_app/features/dashboard/presentation/widgets/budget_categories/budget_categories_grid.dart';
import 'package:spend_io_app/features/dashboard/presentation/widgets/monthly_budget/monthly_budget_progress.dart';
import 'package:spend_io_app/features/dashboard/presentation/widgets/quick_actions/quick_actions_grid.dart';
import 'package:spend_io_app/features/dashboard/presentation/widgets/recent_activity/recent_activity_section.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        //thanh load
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 1));
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              //Header
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                sliver: SliverToBoxAdapter(
                  child: AppHeader(
                    displayName: 'Bunny', //TODO: lấy từ csdl
                    avatarUrl: '',
                    onProfileTap: () {
                      //TODO: điều hướng qua trang Profile
                    },
                    onNotificationTap: () {
                      //TODO: Xử lý chuông tb
                    },
                  ),
                ),
              ),

              //Componet: Summary total balance
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                sliver: SliverToBoxAdapter(
                  child: const BalanceSummaryCard(
                    summary: DashboardMockData.summary,
                  ),
                ),
              ),

              //Component: quick action
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                sliver: SliverToBoxAdapter(
                  child: QuickActionsGrid(
                    onTransactionTap: () {
                      // TODO: chức năng add transaction
                    },
                    onBudgetTap: () {
                      // TODO: chức năng buget
                    },
                    onAnalyticsTap: () {
                      // TODO chức năng xem phân tích
                    },
                  ),
                ),
              ),

              //Conponent: Spending Categories
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                sliver: SliverToBoxAdapter(
                  child: BudgetCategoriesGrid(
                    categories: DashboardMockData.budgetCategories,
                  ),
                ),
              ),

              //Component: finacial pulse
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                sliver: SliverToBoxAdapter(
                  child: MonthlyBudgetProgress(
                    budget: DashboardMockData.monthlyBudget,
                  ),
                ),
              ),

              //Componet: Spending breakdown
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                sliver: SliverToBoxAdapter(
                  child: Container(
                    height: 340,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundLight,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: const Center(
                      child: Text(
                        'Component 6: Spending Breakdown',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textPrimaryLight),
                      ),
                    ),
                  ),
                ),
              ),

              //Component: recent activity
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 40.0),
                sliver: SliverToBoxAdapter(
                  child: RecentActivitySection(
                    transactions: DashboardMockData.recentTransactions,
                    onViewAllTap: () {
                      // TODO: Chuyển sang list chi tiết giao dịch
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
