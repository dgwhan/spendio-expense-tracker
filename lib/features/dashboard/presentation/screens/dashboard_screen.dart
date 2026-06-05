import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/features/dashboard/presentation/widgets/app_header/app_header.dart';
import 'package:spend_io_app/features/dashboard/presentation/widgets/balance_summary/balance_summary_card.dart';
import 'package:spend_io_app/features/dashboard/datasource/mock/dashboard_mock_data.dart';
import 'package:spend_io_app/features/dashboard/presentation/widgets/financial_pulse/financial_pulse_section.dart';
import 'package:spend_io_app/features/dashboard/presentation/widgets/monthly_budget/monthly_budget_progress.dart';
import 'package:spend_io_app/features/dashboard/presentation/widgets/quick_actions/quick_actions_grid.dart';
import 'package:spend_io_app/features/dashboard/presentation/widgets/recent_activity/recent_activity_section.dart';
import 'package:spend_io_app/features/dashboard/presentation/widgets/savings_goal/savings_goal_card.dart';
import 'package:spend_io_app/features/dashboard/presentation/widgets/spending_breakdown/spending_breakdown_section.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _navigateToInsights(BuildContext context) {
    // TODO(dev): Thực hiện logic chuyển đổi Tab Index sang Tab chi tiết
    debugPrint(
        'Hành động: [Spending Breakdown] Chuyển hướng sang tab chi tiết Insights.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            debugPrint(
                'Hành động: [RefreshIndicator] Đang làm mới dữ liệu Dashboard...');
            await Future.delayed(const Duration(seconds: 1));
            debugPrint(
                'Hành động: [RefreshIndicator] Làm mới dữ liệu hoàn tất.');
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Header
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                sliver: SliverToBoxAdapter(
                  child: AppHeader(
                    displayName: 'Bunny', //TODO: lấy từ csdl
                    avatarUrl: '',
                    onProfileTap: () {
                      debugPrint(
                          'Hành động: [AppHeader] Chạm vào Avatar -> Mở màn hình Profile.');
                      //TODO: điều hướng qua trang Profile
                    },
                    onNotificationTap: () {
                      debugPrint(
                          'Hành động: [AppHeader] Chạm vào Chuông -> Mở danh sách thông báo.');
                      //TODO: Xử lý chuông tb
                    },
                  ),
                ),
              ),

              // Component: Summary total balance
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                sliver: SliverToBoxAdapter(
                  child: const BalanceSummaryCard(
                    summary: DashboardMockData.summary,
                  ),
                ),
              ),

              // Component: quick action
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                sliver: SliverToBoxAdapter(
                  child: QuickActionsGrid(
                    onTransactionTap: () {
                      debugPrint('Hành động: chuyển sang thêm giao dịch');
                      // TODO: chức năng add transaction
                    },
                    onBudgetTap: () {
                      debugPrint(
                          'Hành động:chuyển sang trang quản lý ngân sách.');
                      // TODO: chức năng buget
                    },
                    onAnalyticsTap: () {
                      debugPrint(
                          'Hành động: chuyển sang chức năng xem phân tích tài chính.');
                      // TODO chức năng xem phân tích
                    },
                    onSavingGoalTap: () {
                      debugPrint(
                          'Hành động: chuyển sang chức năng mục tiêu tiết kiệm');
                      // TODO chức năng đặt mục tiêu tiết kiệm
                    },
                  ),
                ),
              ),

              // Component: Spending breakdown
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                sliver: SliverToBoxAdapter(
                  child: SpendingBreakdownSection(
                    weekData: DashboardMockData.spendingBreakdownWeek,
                    monthData: DashboardMockData.spendingBreakdownMonth,
                    yearData: DashboardMockData.spendingBreakdownYear,
                    onViewDetailTap: () {
                      debugPrint('Hành động:  xem view detail chi tiết');
                      _navigateToInsights(context);
                    },
                    onViewMoreTap: () {
                      debugPrint('Hành động: nút view more xem thêm');
                      _navigateToInsights(context);
                    },
                  ),
                ),
              ),

              // Component: Financial Pulse (AI Insights & Weekly Density Heatmap)
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                sliver: SliverToBoxAdapter(
                  child: FinancialPulseSection(
                    pulse: DashboardMockData.financialPulse,
                  ),
                ),
              ),

              // Component: Goal Saving
              SliverPadding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                sliver: SliverToBoxAdapter(
                  child: SavingsGoalCard(
                    goals: DashboardMockData.savingsGoals,
                    onViewAllTap: () {
                      debugPrint('Hành động: xem tất cả mục tiêu tích lũy.');
                      // TODO: Chuyển sang trang tất cả mục tiêu tích lũy
                    },
                  ),
                ),
              ),

              // Component: Monthly Budget
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                sliver: SliverToBoxAdapter(
                  child: MonthlyBudgetProgress(
                    budget: DashboardMockData.monthlyBudget,
                  ),
                ),
              ),

              // Component: recent activity
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 40.0),
                sliver: SliverToBoxAdapter(
                  child: RecentActivitySection(
                    transactions: DashboardMockData.recentTransactions,
                    onViewAllTap: () {
                      debugPrint(
                          'Hành động: xem tất cả lịch sử giao dịch gần đây.');
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
