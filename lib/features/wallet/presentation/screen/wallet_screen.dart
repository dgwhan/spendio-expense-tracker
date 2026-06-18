import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/features/account/presentation/screen/utils/account_actions.dart';
import 'package:spend_io_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/features/wallet/presentation/viewmodels/wallet_viewmodel.dart';
import 'package:spend_io_app/features/account/presentation/viewmodels/account_viewmodel.dart';
import 'package:spend_io_app/features/account/presentation/screen/account_details_screen.dart';
import 'package:spend_io_app/features/account/presentation/widgets/accounts_section.dart';
import 'package:spend_io_app/features/account/presentation/screen/account_list_screen.dart';
import 'package:spend_io_app/features/budget/presentation/widgets/budget_section.dart';
import 'package:spend_io_app/features/wallet/presentation/widgets/goals/goals_section.dart';
import 'package:spend_io_app/features/wallet/presentation/widgets/header/wallet_header.dart';
import 'package:spend_io_app/features/wallet/presentation/widgets/hero/total_assets_card.dart';
import 'package:spend_io_app/core/widgets/dialogs/app_month_picker_dialog.dart';

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

  Future<void> _refreshAllWalletData(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final userEntity = auth.currentUser?.toEntity();

    await context.read<WalletViewModel>().initialize();

    if (userEntity != null && context.mounted) {
      final localId = userEntity.id ?? 0;
      final remoteUid = userEntity.id?.toString() ?? '';

      await context.read<AccountViewModel>().loadAccounts(
            localId,
            remoteUid,
            forceRefresh: true,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final errorTextColor = isDark ? AppColors.textPrimaryDark : Colors.black87;

    final accountVM = context.watch<AccountViewModel>();

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Consumer<WalletViewModel>(
        builder: (context, viewModel, child) {
          // Lớp bảo vệ 01: Trạng thái xoay tròn chờ nạp dữ liệu gốc
          if (viewModel.isLoading || accountVM.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          // Lớp bảo vệ 02: Báo lỗi trực quan
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
                      onPressed: () => _refreshAllWalletData(context),
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Lớp hiển thị chính
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
                              builder: (context) => AppMonthPickerDialog(
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
                        BudgetSection(
                          totalSpent: viewModel.totalSpent,
                          totalBudget: viewModel.totalBudget,
                          daysLeft: viewModel.daysLeft,
                          categories: viewModel
                              .categoriesProgress, // 🔴 ĐÃ SỬA: Trỏ chính xác vào categoriesProgress sạch lỗi compile!
                        ),
                      ],
                    ),
                  ),
                ),

                // Phase 02: My Accounts
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                  sliver: AccountsSection(
                    accounts: accountVM.accounts,
                    onViewAll: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AccountListScreen(),
                        ),
                      );
                    },
                    onAccountTap: (account) async {
                      final result = await Navigator.push<AccountDetailsAction>(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              AccountDetailsScreen(account: account),
                        ),
                      );

                      if (!context.mounted || result == null) return;

                      if (result == AccountDetailsAction.deleted ||
                          result == AccountDetailsAction.updated) {
                        _refreshAllWalletData(context);
                      }
                    },
                  ),
                ),

                // Phase 03: Savings Goals
                const SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    AppSizes.md,
                    AppSizes.lg,
                    AppSizes.md,
                    0,
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
