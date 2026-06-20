import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:spend_io_app/features/account/presentation/screen/utils/account_actions.dart';
import 'package:spend_io_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/features/budget/presentation/widgets/wallet_budget_categories_grid.dart';
import 'package:spend_io_app/features/goal/presentation/widgets/goals_section.dart';

import 'package:spend_io_app/features/wallet/presentation/viewmodels/wallet_viewmodel.dart';
import 'package:spend_io_app/features/account/presentation/viewmodels/account_viewmodel.dart';

import 'package:spend_io_app/features/account/presentation/screen/account_details_screen.dart';
import 'package:spend_io_app/features/account/presentation/screen/account_list_screen.dart';

import 'package:spend_io_app/features/account/presentation/widgets/accounts_section.dart';
import 'package:spend_io_app/features/wallet/presentation/widgets/header/wallet_header.dart';
import 'package:spend_io_app/features/wallet/presentation/widgets/hero/total_assets_card.dart';

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
      context.read<WalletViewModel>().updateUser(auth.currentUser?.toEntity());
    });
  }

  Future<void> _refreshAllWalletData(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser?.toEntity();

    await context.read<WalletViewModel>().initialize();

    if (user != null && context.mounted) {
      await context.read<AccountViewModel>().loadAccounts(
            user.id!,
            user.id.toString(),
            forceRefresh: true,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;

    final authProvider = context.read<AuthProvider>();
    final currentUserId = authProvider.currentUser?.toEntity().id ?? 0;

    final accountVM = context.watch<AccountViewModel>();

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Consumer<WalletViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading || accountVM.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vm.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(vm.errorMessage!),
                  ElevatedButton(
                    onPressed: () => _refreshAllWalletData(context),
                    child: const Text("Retry"),
                  ),
                ],
              ),
            );
          }

          return SafeArea(
            top: true,
            child: RefreshIndicator(
              onRefresh: () => _refreshAllWalletData(context),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // ================= APP BAR GHIM TIÊU ĐỀ =================
                  SliverAppBar(
                    pinned: true,
                    floating: false,
                    elevation: 0,
                    centerTitle: true,
                    backgroundColor: backgroundColor,
                    toolbarHeight: 48,
                    title: const WalletHeader(),
                  ),

                  // ================= KHỐI TÀI SẢN (TOTAL ASSETS) =================
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSizes.md,
                        AppSizes.sm,
                        AppSizes.md,
                        0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TotalAssetsCard(summary: vm.summary),
                        ],
                      ),
                    ),
                  ),

                  // ================= NGÂN SÁCH (BUDGET SECTION) =================
                  WalletBudgetCategoriesGrid(userId: currentUserId),

                  // ================= TÀI KHOẢN (ACCOUNTS SECTION) =================
                  SliverToBoxAdapter(
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: AppSizes.md),
                      child: AccountsSection(
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
                  ),

                  // ================= MỤC TIÊU (GOALS SECTION) =================
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppSizes.md,
                        AppSizes.lg,
                        AppSizes.md,
                        0,
                      ),
                      child: GoalsSection(),
                    ),
                  ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppSizes.xl),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
