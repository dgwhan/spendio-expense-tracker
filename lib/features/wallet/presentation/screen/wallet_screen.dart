import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/features/account/presentation/screen/utils/account_actions.dart';
import 'package:spend_io_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/features/budget/presentation/screens/budget_detail_screen.dart';
import 'package:spend_io_app/features/budget/presentation/screens/category/add_category_budget_screen.dart';
import 'package:spend_io_app/features/wallet/presentation/viewmodels/wallet_viewmodel.dart';
import 'package:spend_io_app/features/account/presentation/viewmodels/account_viewmodel.dart';
import 'package:spend_io_app/features/account/presentation/screen/account_details_screen.dart';
import 'package:spend_io_app/features/account/presentation/widgets/accounts_section.dart';
import 'package:spend_io_app/features/account/presentation/screen/account_list_screen.dart';
import 'package:spend_io_app/features/budget/presentation/widgets/section/budget_section.dart';
import 'package:spend_io_app/features/budget/presentation/viewmodels/monthly/budget_form_viewmodel.dart';
import 'package:spend_io_app/features/budget/presentation/viewmodels/category/budget_category_form_viewmodel.dart';
import 'package:spend_io_app/features/budget/presentation/viewmodels/monthly/budget_viewmodel.dart';
import 'package:spend_io_app/features/budget/presentation/screens/monthly/add_budget_screen.dart';
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

  void _navigateToBudgetForm(BuildContext context, int userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider<BudgetFormViewModel>(
          create: (_) => BudgetFormViewModel(),
          child: AddBudgetScreen(userId: userId),
        ),
      ),
    );
  }

  void _navigateToCategoryBudgetForm(BuildContext context, int userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider<BudgetCategoryFormViewModel>(
          create: (_) => BudgetCategoryFormViewModel(),
          child: AddCategoryBudgetScreen(userId: userId),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final errorTextColor = isDark ? AppColors.textPrimaryDark : Colors.black87;

    final authProvider = context.read<AuthProvider>();
    final accountVM = context.read<AccountViewModel>();
    final currentUserId = authProvider.currentUser?.toEntity().id ?? 0;

    return Scaffold(
      body: Consumer2<WalletViewModel, AccountViewModel>(
        builder: (context, viewModel, accountViewModel, child) {
          if (viewModel.isLoading || accountViewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

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

          return SafeArea(
            top: false,
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => _refreshAllWalletData(context),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
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
                          ),
                          const SizedBox(height: AppSizes.xl),
                          BudgetSection(
                            totalSpent: viewModel.totalSpent,
                            totalBudget: viewModel.totalBudget,
                            daysLeft: viewModel.daysLeft,
                            categories: viewModel.categoriesProgress,
                            userId: currentUserId,
                            onCreateBudgetTap: () =>
                                _navigateToBudgetForm(context, currentUserId),
                            onGetDetailBudgetTap: () async {
                              if (viewModel.totalBudget > 0) {
                                debugPrint(
                                    '[PIPELINE INIT]: Loading budget data state container before detail context switch.');
                                await context
                                    .read<BudgetViewModel>()
                                    .loadBudget(currentUserId);

                                if (context.mounted) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => BudgetDetailScreen(
                                        totalSpent: viewModel.totalSpent,
                                        totalBudget: viewModel.totalBudget,
                                        daysLeft: viewModel.daysLeft,
                                        userId: currentUserId,
                                      ),
                                    ),
                                  );
                                }
                              } else {
                                debugPrint(
                                    '[PIPELINE INIT]: Budget is zero. Redirecting to initialization form flow.');
                                if (context.mounted) {
                                  _navigateToBudgetForm(context, currentUserId);
                                }
                              }
                            },
                            onCreateCategoryBudgetTap: () =>
                                _navigateToCategoryBudgetForm(
                                    context, currentUserId),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSizes.md),
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
                        final result =
                            await Navigator.push<AccountDetailsAction>(
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
                  const SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      AppSizes.md,
                      AppSizes.lg,
                      AppSizes.md,
                      0,
                    ),
                    sliver: GoalsSection(),
                  ),
                  const SliverToBoxAdapter(
                      child: SizedBox(height: AppSizes.xl)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
