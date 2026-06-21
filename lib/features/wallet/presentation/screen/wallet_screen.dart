import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';

import 'package:spend_io_app/features/auth/presentation/providers/auth_provider.dart';

import 'package:spend_io_app/features/account/presentation/screen/account_details_screen.dart';
import 'package:spend_io_app/features/account/presentation/screen/account_list_screen.dart';
import 'package:spend_io_app/features/account/presentation/screen/utils/account_actions.dart';
import 'package:spend_io_app/features/account/presentation/viewmodels/account_viewmodel.dart';
import 'package:spend_io_app/features/account/presentation/widgets/accounts_section.dart';

import 'package:spend_io_app/features/budget/presentation/widgets/wallet_budget_categories_grid.dart';
import 'package:spend_io_app/features/saving_goal/presentation/screens/create_saving_goal_screen.dart';
import 'package:spend_io_app/features/saving_goal/presentation/screens/saving_goal_detail_screen.dart';
import 'package:spend_io_app/features/saving_goal/presentation/screens/saving_goal_list_screen.dart';
import 'package:spend_io_app/features/saving_goal/presentation/viewmodels/saving_goal_detail_viewmodel.dart';

import 'package:spend_io_app/features/saving_goal/presentation/viewmodels/saving_goal_list_viewmodel.dart';
import 'package:spend_io_app/features/saving_goal/presentation/widgets/saving_goals_section.dart';

import 'package:spend_io_app/features/wallet/presentation/viewmodels/wallet_viewmodel.dart';
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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = context.read<AuthProvider>();
      final user = auth.currentUser?.toEntity();

      context.read<WalletViewModel>().updateUser(user);

      if (user != null) {
        await context.read<SavingGoalListViewModel>().loadGoals(
              userId: user.id!,
            );
      }
    });
  }

  Future<void> _refreshAllWalletData(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser?.toEntity();

    await context.read<WalletViewModel>().initialize();

    if (user != null && context.mounted) {
      await Future.wait([
        context.read<AccountViewModel>().loadAccounts(
              user.id!,
              user.id.toString(),
              forceRefresh: true,
            ),
        context.read<SavingGoalListViewModel>().loadGoals(
              userId: user.id!,
            ),
      ]);
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
    final goalVM = context.watch<SavingGoalListViewModel>();

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Consumer<WalletViewModel>(
        builder: (context, walletVM, child) {
          if (walletVM.isLoading || accountVM.isLoading || goalVM.loading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (walletVM.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 12),
                  Text(walletVM.errorMessage!),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => _refreshAllWalletData(context),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return SafeArea(
            child: RefreshIndicator(
              onRefresh: () => _refreshAllWalletData(context),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // ==================================================
                  // HEADER
                  // ==================================================

                  SliverAppBar(
                    pinned: true,
                    floating: false,
                    elevation: 0,
                    centerTitle: true,
                    backgroundColor: backgroundColor,
                    toolbarHeight: 48,
                    title: const WalletHeader(),
                  ),

                  // ==================================================
                  // TOTAL ASSETS
                  // ==================================================

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSizes.md,
                        AppSizes.sm,
                        AppSizes.md,
                        0,
                      ),
                      child: TotalAssetsCard(
                        summary: walletVM.summary,
                      ),
                    ),
                  ),

                  // ==================================================
                  // BUDGETS
                  // ==================================================

                  WalletBudgetCategoriesGrid(
                    userId: currentUserId,
                  ),

                  // ==================================================
                  // ACCOUNTS
                  // ==================================================

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.md,
                      ),
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
                              builder: (_) => AccountDetailsScreen(
                                account: account,
                              ),
                            ),
                          );

                          if (!context.mounted || result == null) {
                            return;
                          }

                          if (result == AccountDetailsAction.deleted ||
                              result == AccountDetailsAction.updated) {
                            await _refreshAllWalletData(
                              context,
                            );
                          }
                        },
                      ),
                    ),
                  ),

                  // ==================================================
                  // SAVING GOALS
                  // ==================================================

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSizes.md,
                        AppSizes.lg,
                        AppSizes.md,
                        0,
                      ),
                      child: GoalsSection(
                        goals: goalVM.goals,
                        onViewAll: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SavingGoalListScreen(),
                            ),
                          );
                        },
                        onAddGoal: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CreateSavingGoalScreen(),
                            ),
                          );

                          if (result == true && context.mounted) {
                            await context
                                .read<SavingGoalListViewModel>()
                                .loadGoals(userId: currentUserId);
                          }
                        },
                        onGoalTap: (goal) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChangeNotifierProvider(
                                create: (ctx) => SavingGoalDetailViewModel(
                                  getGoalByIdUseCase: ctx.read(),
                                  getGoalContributionsUseCase: ctx.read(),
                                  addGoalContributionUseCase: ctx.read(),
                                  updateGoalUseCase: ctx.read(),
                                  deleteGoalUseCase: ctx.read(),
                                ),
                                child: SavingGoalDetailScreen(goalId: goal.id),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(
                    child: SizedBox(
                      height: AppSizes.xl,
                    ),
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
