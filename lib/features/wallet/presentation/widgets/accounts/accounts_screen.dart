import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/features/wallet/domain/entities/account_entity.dart';
import 'package:spend_io_app/features/wallet/presentation/widgets/accounts/account_item_card.dart';
import 'package:spend_io_app/shared/widgets/buttons/app_text_button.dart';
import 'package:spend_io_app/features/wallet/presentation/viewmodels/wallet_viewmodel.dart';
import 'add_account_bottom_sheet.dart';
import 'account_details_bottom_sheet.dart';
import 'edit_account_bottom_sheet.dart';

class AccountsScreen extends StatelessWidget {
  final List<AccountEntity> accounts;

  const AccountsScreen({super.key, required this.accounts});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<WalletViewModel>(context, listen: false);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 120.0,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: AppColors.backgroundLight,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: false,
                titlePadding: const EdgeInsetsDirectional.only(
                  start: AppSizes.md,
                  bottom: AppSizes.md,
                ),
                title: const Text(
                  'My Accounts',
                  style: TextStyle(
                    color: AppColors.textPrimaryLight,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: AppSizes.sm),
                  child: AppTextButton(
                    text: 'Add',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => AddAccountBottomSheet(viewModel: viewModel),
                      );
                    },
                  ),
                ),
              ],
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
                  (BuildContext context, int index) {
                    final account = accounts[index];
                    return AccountItemCard(
                      account: account,
                      onTap: () async {
                        final result = await showModalBottomSheet<String>(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => AccountDetailsBottomSheet(account: account),
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
                    );
                  },
                  childCount: accounts.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
