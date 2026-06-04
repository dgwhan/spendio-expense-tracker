import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/extensions/string_extension.dart';
import 'package:spend_io_app/features/dashboard/datasource/models/dashboard_summary_model.dart';

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
    final currencyString = formatter.format(amount).replaceAll('', '');

    return _isObscured ? currencyString.obscure : currencyString;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ---- TOTAL BALANCE----
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL BALANCE',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
              ),
              IconButton(
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
            ],
          ),
          const SizedBox(height: 8),

          Text(
            _formatCurrency(widget.summary.balance),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),

          Container(
            height: 0.5,
            color: Colors.white.withValues(alpha: 0.15),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _StatItem(
                  title: 'INCOME (THIS MONTH)',
                  amountString: _formatCurrency(widget.summary.income),
                  amountColor: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              Expanded(
                child: _StatItem(
                  title: 'EXPENSE (THIS MONTH)',
                  amountString: _formatCurrency(widget.summary.expense),
                  amountColor: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              Expanded(
                child: _StatItem(
                  title: 'SAVINGS (THIS MONTH)',
                  amountString: _formatCurrency(widget.summary.savings),
                  amountColor: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String title;
  final String amountString;
  final Color amountColor;

  const _StatItem({
    required this.title,
    required this.amountString,
    required this.amountColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 9,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          amountString,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: amountColor,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
