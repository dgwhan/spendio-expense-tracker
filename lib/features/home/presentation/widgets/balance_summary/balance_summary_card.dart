import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/extensions/string_extension.dart';
import 'package:spend_io_app/core/utils/currency_formatter.dart';
import 'package:spend_io_app/core/utils/localization.dart';
import 'package:spend_io_app/features/home/data/models/dashboard_summary_model.dart';
import 'package:spend_io_app/core/widgets/cards/app_info_card.dart';

class BalanceSummaryCard extends StatefulWidget {
  final DashboardSummaryModel summary;

  const BalanceSummaryCard({
    super.key,
    required this.summary,
  });

  @override
  State<BalanceSummaryCard> createState() => _BalanceSummaryCardState();
}

class _BalanceSummaryCardState extends State<BalanceSummaryCard> {
  bool _isObscured = false;

  String _formatCurrency(double amount) {
    final currencyString = CurrencyFormatter.format(amount);
    return _isObscured ? currencyString.obscure : currencyString;
  }

  @override
  Widget build(BuildContext context) {
    final thisMonthStr = AppLocalizations.translate('this_month').toUpperCase();

    return AppInfoCard(
      title: AppLocalizations.translate('total_balance').toUpperCase(),
      mainBalance: _formatCurrency(widget.summary.balance),
      trailingIcon: IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        icon: Icon(
          _isObscured
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          color: Colors.white.withValues(alpha: 0.8),
          size: 20,
        ),
        onPressed: () {
          setState(() {
            _isObscured = !_isObscured;
          });
        },
      ),
      items: [
        AppInfoItem(
          label: '${AppLocalizations.translate('income')} ($thisMonthStr)',
          value: _formatCurrency(widget.summary.income),
          valueColor: AppColors.income,
        ),
        AppInfoItem(
          label: '${AppLocalizations.translate('expense')} ($thisMonthStr)',
          value: _formatCurrency(widget.summary.expense),
          valueColor: AppColors.expense,
        ),
        AppInfoItem(
          label: '${AppLocalizations.translate('savings').toUpperCase()} ($thisMonthStr)',
          value: _formatCurrency(widget.summary.savings),
          valueColor: Colors.white.withValues(alpha: 0.9),
        ),
      ],
    );
  }
}

