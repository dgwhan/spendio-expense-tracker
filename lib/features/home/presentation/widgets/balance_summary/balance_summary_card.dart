import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/extensions/string_extension.dart';
import 'package:spend_io_app/features/home/data/models/dashboard_summary_model.dart';
import 'package:spend_io_app/shared/cards/summary_card.dart';

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
    final formatter =
        NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
    final currencyString = formatter.format(amount).replaceAll(' ', '');

    return _isObscured ? currencyString.obscure : currencyString;
  }

  @override
  Widget build(BuildContext context) {
    return SummaryCard(
      title: 'TOTAL BALANCE',
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
        SummaryItem(
          label: 'INCOME (THIS MONTH)',
          value: _formatCurrency(widget.summary.income),
          valueColor: AppColors.income,
        ),
        SummaryItem(
          label: 'EXPENSE (THIS MONTH)',
          value: _formatCurrency(widget.summary.expense),
          valueColor: AppColors.expense,
        ),
        SummaryItem(
          label: 'SAVINGS (THIS MONTH)',
          value: _formatCurrency(widget.summary.savings),
          valueColor: Colors.white.withValues(alpha: 0.9),
        ),
      ],
    );
  }
}
