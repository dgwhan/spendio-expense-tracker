import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/utils/currency_formatter.dart';
import 'package:spend_io_app/core/utils/transaction_grouping.dart';
import 'package:spend_io_app/features/account/presentation/viewmodels/account_details_viewmodel.dart';
import 'package:spend_io_app/features/account/presentation/widgets/transaction/account_detail_transaction_tile.dart';

class AccountTransactionFeed extends StatelessWidget {
  final TransactionLedgerState? ledgerState;
  final Color primaryTextColor;
  final Color mutedTextColor;

  const AccountTransactionFeed({
    super.key,
    required this.ledgerState,
    required this.primaryTextColor,
    required this.mutedTextColor,
  });

  String _formatGroupHeaderDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateZero = DateTime(date.year, date.month, date.day);
    final formatted = DateFormat('MMMM d').format(date).toUpperCase();

    if (dateZero.isAtSameMomentAs(today)) return 'TODAY - $formatted';
    if (dateZero.isAtSameMomentAs(yesterday)) return 'YESTERDAY - $formatted';
    return '${DateFormat('EEEE').format(date).toUpperCase()} - $formatted';
  }

  String _formatNetTotal(double net) {
    final formatted = CurrencyFormatter.format(net.abs());
    return net > 0 ? '+$formatted' : (net < 0 ? '-$formatted' : formatted);
  }

  @override
  Widget build(BuildContext context) {
    if (ledgerState == null) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (ledgerState!.dayGroups.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 48,
                color: mutedTextColor.withOpacity(0.5),
              ),
              const SizedBox(height: AppSizes.md),
              Text(
                'No Transactions Found',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor,
                ),
              ),
              const SizedBox(height: AppSizes.xs),
              Text(
                'Try modifying search keyword or active date range filter.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: mutedTextColor),
              ),
            ],
          ),
        ),
      );
    }

    return SliverMainAxisGroup(
      slivers: [
        for (final group in ledgerState!.dayGroups) ...[
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.md,
              AppSizes.md,
              AppSizes.md,
              AppSizes.xs,
            ),
            sliver: SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatGroupHeaderDate(group.date),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: mutedTextColor,
                    ),
                  ),
                  Text(
                    _formatNetTotal(group.totalIncome - group.totalExpense),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: (group.totalIncome - group.totalExpense) >= 0
                          ? AppColors.success
                          : AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) =>
                  AccountDetailTransactionTile(tx: group.items[index]),
              childCount: group.items.length,
            ),
          ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }
}
