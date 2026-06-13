import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/features/wallet/domain/entities/account_entity.dart';
import 'package:spend_io_app/features/wallet/presentation/viewmodels/wallet_viewmodel.dart';
import 'package:spend_io_app/features/wallet/presentation/widgets/accounts/account_details_bottom_sheet.dart';
import 'package:spend_io_app/features/wallet/presentation/widgets/accounts/account_item_card.dart';
import 'package:spend_io_app/features/wallet/presentation/widgets/accounts/add_account_bottom_sheet.dart';
import 'package:spend_io_app/features/wallet/presentation/widgets/accounts/edit_account_bottom_sheet.dart';
import 'package:spend_io_app/shared/widgets/buttons/app_text_button.dart';
import 'package:spend_io_app/core/widgets/common/app_empty_state.dart';

class AccountListScreen extends StatelessWidget {
  const AccountListScreen({super.key});

  void _openAddAccount(BuildContext context, WalletViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddAccountBottomSheet(viewModel: viewModel),
    );
  }

  void _handleAccountTap(BuildContext context, WalletViewModel viewModel, AccountEntity account) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AccountDetailsBottomSheet(account: account),
    );

    if (!context.mounted) return;

    if (result == 'edit') {
      showModalBottomSheet(
        context: context,
        useRootNavigator: true,
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
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? AppColors.textPrimaryDark : const Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Accounts',
          style: TextStyle(
            color: titleColor,
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
        actions: [
          Consumer<WalletViewModel>(
            builder: (context, viewModel, _) {
              return Padding(
                padding: const EdgeInsets.only(right: AppSizes.md),
                child: Center(
                  child: AppTextButton(
                    text: 'Add',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    onTap: () => _openAddAccount(context, viewModel),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<WalletViewModel>(
        builder: (context, viewModel, _) {
          final activeAccounts = viewModel.accounts;

          if (activeAccounts.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.lg),
                child: AppEmptyState(
                  title: 'No Accounts Yet',
                  subtitle: 'Add your first account\nto start tracking money.',
                  icon: Icons.account_balance_wallet_outlined,
                  actionLabel: 'Add Your First Account',
                  onActionTap: () => _openAddAccount(context, viewModel),
                ),
              ),
            );
          }

          return SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.md,
                    vertical: AppSizes.md,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final account = activeAccounts[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSizes.md),
                          child: AccountItemCard(
                            account: account,
                            onTap: () => _handleAccountTap(context, viewModel, account),
                          ),
                        );
                      },
                      childCount: activeAccounts.length,
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
