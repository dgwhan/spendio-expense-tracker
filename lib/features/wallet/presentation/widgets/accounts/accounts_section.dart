import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/features/wallet/data/datasource/wallet_local_data_source.dart';
import 'package:spend_io_app/features/wallet/domain/entities/account_entity.dart';
import 'package:spend_io_app/features/wallet/presentation/widgets/accounts/account_item_card.dart';
import 'package:spend_io_app/shared/widgets/buttons/app_text_button.dart';

class AccountsSection extends StatelessWidget {
  const AccountsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final List<AccountEntity> liveAccounts = WalletLocalDataSource.accounts;

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
                    text: '+ Add',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    onTap: () {
                      // TODO: Logic khi nhấn nút thêm tài khoản ở đây
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
                    final account = liveAccounts[index];
                    return AccountItemCard(
                      account: account,
                      onTap: () {
                        // TODO: Xem chi tiết tài khoản
                      },
                    );
                  },
                  childCount: liveAccounts.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
