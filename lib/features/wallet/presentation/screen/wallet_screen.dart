import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/features/wallet/presentation/viewmodels/wallet_viewmodel.dart';
import 'package:spend_io_app/features/wallet/presentation/widgets/accounts/account_details_bottom_sheet.dart';
import 'package:spend_io_app/features/wallet/presentation/widgets/accounts/accounts_section.dart';
import 'package:spend_io_app/features/wallet/presentation/widgets/accounts/add_account_bottom_sheet.dart';
import 'package:spend_io_app/features/wallet/presentation/widgets/budget/budget_section.dart';
import 'package:spend_io_app/features/wallet/presentation/widgets/goals/goals_section.dart';
import 'package:spend_io_app/features/wallet/presentation/widgets/header/wallet_header.dart';
import 'package:spend_io_app/features/wallet/presentation/widgets/hero/total_assets_card.dart';
import 'package:spend_io_app/features/wallet/presentation/widgets/quick_actions/quick_actions_section.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final vm = context.read<WalletViewModel>();
      vm.updateUser(auth.currentUser);
    });
  }

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
          // Lớp bảo vệ 01: Hiển thị trạng thái xoay tròn chờ nạp dữ liệu từ DB/Firebase, tránh lỗi trắng màn hình
          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          // Lớp bảo vệ 02: Hiển thị giao diện báo lỗi trực quan nếu tầng Data gặp sự cố
          if (viewModel.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.lg),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 48),
                    const SizedBox(height: AppSizes.md),
                    Text(
                      'Đã xảy ra lỗi: ${viewModel.errorMessage}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black87),
                    ),
                    const SizedBox(height: AppSizes.md),
                    ElevatedButton(
                      onPressed: () => viewModel.fetchWalletData(),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Lớp hiển thị chính: Chỉ vẽ cây Widget khi mọi dữ liệu dạng mảng đã sẵn sàng
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
                        TotalAssetsCard(
                          summary: viewModel.summary,
                          healthStatus: viewModel.healthStatus,
                        ),
                        const SizedBox(height: AppSizes.xl),
                        const QuickActionsSection(),
                        const SizedBox(height: AppSizes.xl),
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

                // Phase 02: My Accounts (Hiển thị danh sách ví tài khoản)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                  sliver: SliverToBoxAdapter(
                    child: AccountsSection(
                      accounts: viewModel.accounts,
                      onAddAccount: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) =>
                              AddAccountBottomSheet(viewModel: viewModel),
                        );
                      },
                      onAccountTap: (account) {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) =>
                              AccountDetailsBottomSheet(account: account),
                        );
                      },
                    ),
                  ),
                ),

                // Phase 03: Savings Goals (Đặt mục tiêu tiết kiệm)
                const SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    AppSizes.md, // Left
                    AppSizes
                        .lg, // Top (Đã sửa từ AppColors.error thành AppSizes.lg)
                    AppSizes.md, // Right
                    0, // Bottom
                  ),
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
