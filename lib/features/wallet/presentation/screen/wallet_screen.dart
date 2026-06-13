import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/features/wallet/presentation/viewmodels/wallet_viewmodel.dart';
import 'package:spend_io_app/features/wallet/presentation/widgets/accounts/account_details_bottom_sheet.dart';
import 'package:spend_io_app/features/wallet/presentation/widgets/accounts/accounts_section.dart';
import 'package:spend_io_app/features/wallet/presentation/screen/account_list_screen.dart';
import 'package:spend_io_app/features/wallet/presentation/widgets/accounts/add_account_bottom_sheet.dart';
import 'package:spend_io_app/features/wallet/presentation/widgets/accounts/edit_account_bottom_sheet.dart';
import 'package:spend_io_app/features/wallet/presentation/widgets/budget/budget_section.dart';
import 'package:spend_io_app/features/wallet/presentation/widgets/goals/goals_section.dart';
import 'package:spend_io_app/features/wallet/presentation/widgets/goals/add_goal_bottom_sheet.dart';
import 'package:spend_io_app/features/wallet/presentation/widgets/header/wallet_header.dart';
import 'package:spend_io_app/features/wallet/presentation/widgets/hero/total_assets_card.dart';
import 'package:spend_io_app/features/wallet/presentation/widgets/quick_actions/quick_actions_section.dart';
import 'package:spend_io_app/features/wallet/presentation/widgets/dialogs/month_picker_dialog.dart';

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
      vm.updateUser(auth.currentUser?.toEntity());
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final errorTextColor = isDark ? AppColors.textPrimaryDark : Colors.black87;

    return Scaffold(
      backgroundColor: backgroundColor,
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
                      style: TextStyle(color: errorTextColor),
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
                          onMonthTap: () async {
                            final picked = await showDialog<DateTime>(
                              context: context,
                              builder: (context) => MonthPickerDialog(
                                initialDate: viewModel.selectedMonth,
                              ),
                            );
                            if (picked != null) {
                              viewModel.selectMonth(picked);
                            }
                          },
                        ),
                        const SizedBox(height: AppSizes.lg),
                        TotalAssetsCard(
                          summary: viewModel.summary,
                          healthStatus: viewModel.healthStatus,
                        ),
                        const SizedBox(height: AppSizes.xl),
                        QuickActionsSection(
                          onAddAccount: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) =>
                                  AddAccountBottomSheet(viewModel: viewModel),
                            );
                          },
                          onAddGoal: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) =>
                                  AddGoalBottomSheet(viewModel: viewModel),
                            );
                          },
                          onAddBudget: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Add Budget feature will be available in Phase 02'),
                                backgroundColor: AppColors.primary,
                              ),
                            );
                          },
                          onTransfer: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Transfer feature will be available in Phase 02'),
                                backgroundColor: AppColors.primary,
                              ),
                            );
                          },
                        ),
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
                  sliver: AccountsSection(
                    accounts: viewModel.accounts,
                    onViewAll: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AccountListScreen(),
                        ),
                      );
                    },
                    onAccountTap: (account) async {
                      final result = await showModalBottomSheet<String>(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) =>
                            AccountDetailsBottomSheet(account: account),
                      );

                      if (!context.mounted) return;

                      if (result == 'edit') {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => EditAccountBottomSheet(
                            viewModel: viewModel,
                            account: account,
                          ),
                        );
                      } else if (result == 'delete') {
                        viewModel.deleteAccount(account.id).then((_) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Account deleted successfully!'),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          }
                        });
                      }
                    },
                  ),
                ),

                // Phase 03: Savings Goals (Đặt mục tiêu tiết kiệm)
                const SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    AppSizes.md, // Left
                    AppSizes.lg, // Top
                    AppSizes.md, // Right
                    0, // Bottom
                  ),
                  sliver: GoalsSection(),
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
