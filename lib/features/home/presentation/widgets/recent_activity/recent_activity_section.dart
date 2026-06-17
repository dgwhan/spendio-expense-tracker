import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/features/home/presentation/widgets/shared/dashboard_section_container.dart';
import 'package:spend_io_app/features/home/presentation/widgets/recent_activity/transaction_tile.dart';
import 'package:spend_io_app/features/home/data/models/recent_transaction_model.dart';
import 'package:spend_io_app/shared/widgets/buttons/app_text_button.dart';

class RecentActivitySection extends StatefulWidget {
  final List<RecentTransactionModel> transactions;
  final VoidCallback? onViewAllTap;

  const RecentActivitySection({
    super.key,
    required this.transactions,
    this.onViewAllTap,
  });

  @override
  State<RecentActivitySection> createState() => _RecentActivitySectionState();
}

class _RecentActivitySectionState extends State<RecentActivitySection> {
  bool _isExpanded = false;
  final int _collapsedCount = 3;
  final int _maxHomeCount = 10;

  @override
  Widget build(BuildContext context) {
    final totalAvailable = widget.transactions.take(_maxHomeCount).toList();

    final displayTransactions = _isExpanded
        ? totalAvailable
        : totalAvailable.take(_collapsedCount).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title Header Section
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
                onPressed: widget.onViewAllTap,
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

        // Khung danh sách giao dịch
        if (displayTransactions.isNotEmpty) ...[
          DashboardSectionContainer(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: displayTransactions.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: AppColors.borderLight,
                  ),
                  itemBuilder: (context, index) {
                    return TransactionTile(
                        transaction: displayTransactions[index]);
                  },
                ),
                if (totalAvailable.length > _collapsedCount) ...[
                  Divider(height: 1, color: AppColors.borderLight),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Center(
                      child: AppTextButton(
                        text: _isExpanded ? 'See Less' : 'See More',
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        onTap: () {
                          setState(() {
                            _isExpanded = !_isExpanded;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}
