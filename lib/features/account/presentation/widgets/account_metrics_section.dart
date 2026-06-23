import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/features/account/domain/entities/account_entity.dart';
import 'package:spend_io_app/features/account/presentation/widgets/filter/account_detail_filter_capsule.dart';
import 'package:spend_io_app/features/account/presentation/widgets/hero/account_detail_hero_card.dart';
import 'package:spend_io_app/features/account/presentation/widgets/transaction/account_detail_summary_pills.dart';

class AccountMetricsSection extends StatelessWidget {
  final AccountEntity account;
  final String activeRangeDisplay;
  final double totalReceived;
  final double totalSpent;
  final Function(String) onPresetSelected;
  final VoidCallback onCustomRangeTap;

  const AccountMetricsSection({
    super.key,
    required this.account,
    required this.activeRangeDisplay,
    required this.totalReceived,
    required this.totalSpent,
    required this.onPresetSelected,
    required this.onCustomRangeTap,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AccountDetailHeroCard(account: account),
            const SizedBox(height: AppSizes.md),
            AccountDetailFilterCapsule(
              activeRangeDisplay: activeRangeDisplay,
              onPresetSelected: onPresetSelected,
              onCustomRangeTap: onCustomRangeTap,
            ),
            const SizedBox(height: AppSizes.md),
            AccountDetailSummaryPills(
              totalReceived: totalReceived,
              totalSpent: totalSpent,
              currencyCode: account.currencyCode,
            ),
            const SizedBox(height: AppSizes.md),
          ],
        ),
      ),
    );
  }
}
