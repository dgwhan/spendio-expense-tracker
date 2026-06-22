import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/constants/app_text_styles.dart';
import 'package:spend_io_app/core/utils/currency_formatter.dart';
import 'package:spend_io_app/core/widgets/app_header.dart';
import 'package:spend_io_app/core/widgets/common/app_empty_state.dart';
import 'package:spend_io_app/core/widgets/input/app_search_bar.dart';
import 'package:spend_io_app/core/widgets/primary_button.dart';
import 'package:spend_io_app/features/account/domain/entities/account_entity.dart';
import 'package:spend_io_app/features/account/presentation/screen/account_details_screen.dart';
import 'package:spend_io_app/features/account/presentation/screen/add_account_screen.dart';
import 'package:spend_io_app/features/account/presentation/screen/utils/account_actions.dart';
import 'package:spend_io_app/features/account/presentation/viewmodels/account_viewmodel.dart';
import 'package:spend_io_app/features/account/presentation/widgets/card/account_item_card.dart';
import 'package:spend_io_app/features/account/presentation/widgets/filter/account_list_subheader.dart';

class AccountListScreen extends StatefulWidget {
  const AccountListScreen({super.key});

  @override
  State<AccountListScreen> createState() => _AccountListScreenState();
}

class _AccountListScreenState extends State<AccountListScreen> {
  AccountSortOption _currentSort = AccountSortOption.newest;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  void _openAddAccount(BuildContext context, AccountViewModel viewModel) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => AddAccountScreen(viewModel: viewModel)),
    );
    if (!context.mounted || result != true) return;
    _showStatusSnackBar(
        context, 'New account created successfully!', AppColors.success);
  }

  void _showStatusSnackBar(
      BuildContext context, String message, Color backgroundColor) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.removeCurrentSnackBar();
    final headerHeight = kToolbarHeight + MediaQuery.of(context).padding.top;
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(message,
            style: AppTextStyles.bodyNormal
                .copyWith(fontWeight: FontWeight.w600, color: AppColors.white)),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height - (headerHeight + 130),
            left: AppSizes.md,
            right: AppSizes.md),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _handleAccountTap(BuildContext context, AccountViewModel viewModel,
      AccountEntity account) async {
    final Object? result = await Navigator.push<Object?>(
      context,
      MaterialPageRoute(builder: (_) => AccountDetailsScreen(account: account)),
    );
    if (!context.mounted || result == null) return;
    if (result == AccountDetailsAction.deleted || result == true) {
      _showStatusSnackBar(
          context, 'Account deleted successfully!', AppColors.error);
    } else if (result == AccountDetailsAction.updated) {
      _showStatusSnackBar(
          context, 'Account updated successfully!', AppColors.success);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final surfaceColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final primaryTextColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedTextColor =
        isDark ? AppColors.textMutedDark : AppColors.textMutedLight;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppHeader(
          title: 'My Accounts',
          showBack: true,
          onBack: () => Navigator.pop(context)),
      body: Consumer<AccountViewModel>(
        builder: (context, viewModel, _) {
          final sortedAccounts = List.from(viewModel.accounts.where((a) =>
              a.name.toLowerCase().contains(_searchQuery.toLowerCase())));

          switch (_currentSort) {
            case AccountSortOption.nameAZ:
              sortedAccounts.sort((a, b) =>
                  a.name.toLowerCase().compareTo(b.name.toLowerCase()));
              break;
            case AccountSortOption.newest:
              sortedAccounts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
              break;
            case AccountSortOption.oldest:
              sortedAccounts.sort((a, b) => a.createdAt.compareTo(b.createdAt));
              break;
          }

          final double totalNetWorth =
              sortedAccounts.fold(0, (sum, acc) => sum + acc.balance);

          return SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Net worth card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: surfaceColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4))
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Total Assets',
                                        style: AppTextStyles.caption
                                            .copyWith(color: mutedTextColor)),
                                    Text(
                                        CurrencyFormatter.format(totalNetWorth),
                                        style: AppTextStyles.largeAmount
                                            .copyWith(
                                                color: totalNetWorth < 0
                                                    ? AppColors.error
                                                    : primaryTextColor)),
                                  ],
                                ),
                              ),
                              AppButton(
                                  title: 'Add',
                                  onPressed: () =>
                                      _openAddAccount(context, viewModel)),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppSizes.md),

                        // Hàng 1: Tiêu đề danh sách
                        Text('Accounts List',
                            style: AppTextStyles.sectionTitle.copyWith(
                                color: primaryTextColor, fontSize: 15)),

                        const SizedBox(height: AppSizes.sm),

                        // Hàng 2: Search Bar + Filter
                        Row(
                          children: [
                            Expanded(
                              child: AppSearchBar(
                                controller: _searchController,
                                hintText: 'Search...',
                                onChanged: (v) =>
                                    setState(() => _searchQuery = v),
                                onClear: () =>
                                    setState(() => _searchQuery = ''),
                              ),
                            ),
                            const SizedBox(width: AppSizes.sm),
                            AccountListSubheader(
                              currentSort: _currentSort,
                              onSortSelected: (option) =>
                                  setState(() => _currentSort = option),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (sortedAccounts.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: AppEmptyState(
                      title: 'No Accounts Yet',
                      subtitle:
                          'Add your first account\nto start tracking money.',
                      icon: Icons.account_balance_wallet_outlined,
                      actionLabel: 'Add Your First Account',
                      onActionTap: () => _openAddAccount(context, viewModel),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSizes.md, 0, AppSizes.md, AppSizes.md),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSizes.md),
                          child: AccountItemCard(
                            account: sortedAccounts[index],
                            onTap: () => _handleAccountTap(
                                context, viewModel, sortedAccounts[index]),
                          ),
                        ),
                        childCount: sortedAccounts.length,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
