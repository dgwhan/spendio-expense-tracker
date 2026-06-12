import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 1. IMPORT PROVIDER ĐỂ DÙNG CONSUMER
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/features/wallet/presentation/viewmodels/wallet_viewmodel.dart';
import 'package:spend_io_app/features/wallet/presentation/widgets/accounts/accounts_section.dart';
import 'package:spend_io_app/features/wallet/presentation/widgets/budget/budget_section.dart';
import 'package:spend_io_app/features/wallet/presentation/widgets/goals/goals_section.dart';
import 'package:spend_io_app/features/wallet/presentation/widgets/header/wallet_header.dart';
import 'package:spend_io_app/features/wallet/presentation/widgets/hero/total_assets_card.dart';
import 'package:spend_io_app/features/wallet/presentation/widgets/quick_actions/quick_actions_section.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  void _handleGenerateReport(BuildContext context, WalletViewModel viewModel) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Generating report for ${viewModel.selectedMonth.month}/${viewModel.selectedMonth.year}...',
        ),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Consumer<WalletViewModel>(
        builder: (context, viewModel, child) {
          return SafeArea(
            top: false,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Phase 01: Toàn bộ phần đầu & Khối Quản lý Ngân sách (Budget)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSizes.md,
                    AppSizes.xl * 1.5,
                    AppSizes.md,
                    0,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        WalletHeader(
                          selectedMonth: viewModel.selectedMonth,
                          onGenerateReport: () =>
                              _handleGenerateReport(context, viewModel),
                        ),
                        const SizedBox(height: AppSizes.lg),

                        // CARD hiển thị tổng tài sản
                        TotalAssetsCard(
                          summary: viewModel.summary,
                          healthStatus: viewModel.healthStatus,
                        ),
                        const SizedBox(height: AppSizes.xl),
                        const QuickActionsSection(),
                        const SizedBox(height: AppSizes.xl),

                        // BUDGET hiển thị chi tiêu động từ viewModel
                        BudgetSection(
                          totalSpent: viewModel.totalSpent,
                          totalBudget: viewModel.totalBudget,
                          daysLeft: viewModel.daysLeft,
                          categories: viewModel.categories,
                        ),
                      ],
                    ),
                  ),
                ),

                // Phase 02: My Accounts (Hiển thị danh sách tài khoản)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                  sliver: SliverToBoxAdapter(
                    child: AccountsSection(
                      accounts: viewModel.accounts,
                      onAddAccount: () {
                        // Handle add account logic
                      },
                      onAccountTap: (account) {
                        // TODO: Xem chi tiết lịch sử giao dịch tài khoản
                      },
                    ),
                  ),
                ),

                // Phase 03: Savings Goals (Đặt mục tiêu tiết kiệm)
                const SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                      AppSizes.md, AppSizes.lg, AppSizes.md, 0),
                  sliver: SliverToBoxAdapter(
                    child: GoalsSection(),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: AppSizes.xl)),
              ],
            ),
          );
        },
      ),
    );
  }
}
