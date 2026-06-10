import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/features/wallet/data/datasource/wallet_local_data_source.dart';
import 'package:spend_io_app/features/wallet/data/viewmodels/wallet_viewmodel.dart';
import 'package:spend_io_app/features/wallet/presentation/widgets/accounts/account_item_card.dart';

import 'package:spend_io_app/features/wallet/presentation/widgets/budget/wallet_budget_categories_grid.dart';
import 'package:spend_io_app/features/wallet/presentation/widgets/goals/goals_section.dart';
import 'package:spend_io_app/features/wallet/presentation/widgets/hero/total_assets_card.dart';
import 'package:spend_io_app/features/wallet/presentation/widgets/header/wallet_header.dart';
import 'package:spend_io_app/features/wallet/presentation/widgets/quick_actions/quick_actions_section.dart';
import 'package:spend_io_app/features/wallet/presentation/widgets/budget/budget_header.dart';
import 'package:spend_io_app/features/wallet/presentation/widgets/budget/monthly_budget_card.dart';
import 'package:spend_io_app/shared/widgets/buttons/app_text_button.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  late final WalletViewmodel _viewmodel;

  @override
  void initState() {
    super.initState();
    _viewmodel = WalletViewmodel();
    _viewmodel.addListener(_onViewModelUpdated);
  }

  @override
  void dispose() {
    _viewmodel.removeListener(_onViewModelUpdated);
    _viewmodel.dispose();
    super.dispose();
  }

  void _onViewModelUpdated() {
    setState(() {});
  }

  void _handleGenerateReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Generating report for ${_viewmodel.selectedMonth.month}/${_viewmodel.selectedMonth.year}...'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String currentLocale = Localizations.localeOf(context).toString();
    final String currentCurrency =
        currentLocale.startsWith('vi') ? 'VND' : 'USD';
    final liveAccounts = WalletLocalDataSource.accounts;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                  AppSizes.md, AppSizes.xl * 1.5, AppSizes.md, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header (Wallet Title & Generate Report)
                    WalletHeader(
                      selectedMonth: _viewmodel.selectedMonth,
                      onGenerateReport: _handleGenerateReport,
                    ),
                    const SizedBox(height: AppSizes.lg),

                    // Card Tổng tài sản
                    TotalAssetsCard(
                      summary: _viewmodel.summary,
                      healthStatus: _viewmodel.healthStatus,
                      locale: currentLocale,
                      currencyCode: currentCurrency,
                    ),
                    const SizedBox(height: AppSizes.xl),

                    // Thanh hành động nhanh (Quick Actions)
                    const QuickActionsSection(),
                    const SizedBox(height: AppSizes.xl),

                    // Header phân đoạn ngân sách
                    const BudgetHeader(
                      title: 'June Budget',
                      statusLabel: 'SAFE',
                    ),
                    const SizedBox(height: AppSizes.md),

                    // Card tiến độ chi tiêu tổng
                    MonthlyBudgetCard(
                      spent: _viewmodel.totalSpent,
                      budget: _viewmodel.totalBudget,
                      daysLeft: _viewmodel.daysLeft,
                    ),
                    const SizedBox(height: AppSizes.md),

                    // Lưới danh mục chi tiêu ngân sách chi tiết
                    WalletBudgetCategoriesGrid(
                      categories: _viewmodel.categories,
                    ),
                    const SizedBox(height: AppSizes.xl),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'My Accounts',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                    AppTextButton(
                      text: 'Add',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      onTap: () {
                        // Handle add account logic
                      },
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(AppSizes.md),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: AppSizes.md,
                  crossAxisSpacing: AppSizes.md,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final account = liveAccounts[index];
                    return AccountItemCard(
                      account: account,
                      onTap: () {
                        // TODO: Xem chi tiết lịch sử giao dịch tài khoản
                      },
                    );
                  },
                  childCount: liveAccounts.length,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                  AppSizes.md, AppSizes.lg, AppSizes.md, 0),
              sliver: const SliverToBoxAdapter(
                child: GoalsSection(),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSizes.xl))
          ],
        ),
      ),
    );
  }
}
