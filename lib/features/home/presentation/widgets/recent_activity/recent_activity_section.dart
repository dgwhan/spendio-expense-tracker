import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/constants/app_text_styles.dart';
import 'package:spend_io_app/core/utils/localization.dart';
import 'package:spend_io_app/features/home/presentation/widgets/recent_activity/transaction_tile.dart';
import 'package:spend_io_app/features/home/data/models/recent_transaction_model.dart';
import 'package:spend_io_app/core/widgets/button/app_text_button.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalAvailable = widget.transactions.take(_maxHomeCount).toList();

    final displayTransactions = _isExpanded
        ? totalAvailable
        : totalAvailable.take(_collapsedCount).toList();

    final titleColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 4.0, vertical: AppSizes.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.translate('recent_transactions'),
                style: AppTextStyles.sectionTitle.copyWith(
                  color: titleColor,
                ),
              ),
              AppTextButton(
                text: AppLocalizations.translate('view_all'),
                fontWeight: FontWeight.bold,
                fontSize: 13,
                onTap: widget.onViewAllTap,
              ),
            ],
          ),
        ),

        if (displayTransactions.isNotEmpty) ...[
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displayTransactions.length,
            itemBuilder: (context, index) {
              return TransactionTile(
                transaction: displayTransactions[index],
              );
            },
          ),

          // Nút mở rộng See More / See Less đặt thoáng ở cuối danh sách
          if (totalAvailable.length > _collapsedCount) ...[
            const SizedBox(height: AppSizes.xs),
            Center(
              child: AppTextButton(
                text: _isExpanded
                    ? AppLocalizations.translate('see_less')
                    : AppLocalizations.translate('see_more'),
                fontWeight: FontWeight.bold,
                fontSize: 13,
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
              ),
            ),
          ],
        ],
      ],
    );
  }
}
