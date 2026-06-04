import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/features/dashboard/presentation/widgets/shared/dashboard_section_container.dart';
import 'package:spend_io_app/features/dashboard/presentation/widgets/recent_activity/transaction_tile.dart';
import 'package:spend_io_app/features/dashboard/datasource/models/recent_transaction_model.dart';

class RecentActivitySection extends StatelessWidget {
  final List<RecentTransactionModel> transactions;
  final VoidCallback? onViewAllTap;

  const RecentActivitySection({
    super.key,
    required this.transactions,
    this.onViewAllTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activity',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryLight,
                    ),
              ),
              TextButton(
                onPressed: onViewAllTap,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
        DashboardSectionContainer(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactions.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: AppColors.borderLight,
            ),
            itemBuilder: (context, index) {
              return TransactionTile(transaction: transactions[index]);
            },
          ),
        ),
      ],
    );
  }
}
