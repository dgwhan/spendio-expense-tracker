import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/features/wallet/datasource/viewmodels/wallet_viewmodel.dart';
import 'package:spend_io_app/features/wallet/presentation/widgets/budget/wallet_budget_categories_grid.dart';
import 'package:spend_io_app/features/wallet/presentation/widgets/hero/total_assets_card.dart';
import 'package:spend_io_app/features/wallet/presentation/widgets/header/wallet_header.dart';
import 'package:spend_io_app/features/wallet/presentation/widgets/quick_actions/quick_actions_section.dart';
import 'package:spend_io_app/features/wallet/presentation/widgets/budget/budget_header.dart';
import 'package:spend_io_app/features/wallet/presentation/widgets/budget/monthly_budget_card.dart';

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

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSizes.sm),

              // 1. Header (Wallet Title & Generate Report)
              WalletHeader(
                selectedMonth: _viewmodel.selectedMonth,
                onGenerateReport: _handleGenerateReport,
              ),
              const SizedBox(height: AppSizes.lg),

              // 2. Card Tổng tài sản
              TotalAssetsCard(
                summary: _viewmodel.summary,
                healthStatus: _viewmodel.healthStatus,
                locale: currentLocale,
                currencyCode: currentCurrency,
              ),
              const SizedBox(height: AppSizes.xl),

              // 3. Thanh hành động nhanh (Quick Actions)
              const QuickActionsSection(),
              const SizedBox(height: AppSizes.xl),

              // 4. Header phân đoạn ngân sách (Dùng file trong thư mục budget của má)
              const BudgetHeader(
                title: 'June Budget',
                statusLabel: 'SAFE',
              ),
              const SizedBox(height: AppSizes.md),

              // 5. Card tiến độ chi tiêu tổng (Dùng file trong thư mục budget của má)
              MonthlyBudgetCard(
                spent: _viewmodel.totalSpent,
                budget: _viewmodel.totalBudget,
                daysLeft: _viewmodel.daysLeft,
              ),
              const SizedBox(height: AppSizes.md),

              // 6. Lưới danh mục chi tiêu ngân sách chi tiết
              WalletBudgetCategoriesGrid(
                categories: _viewmodel.categories,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
