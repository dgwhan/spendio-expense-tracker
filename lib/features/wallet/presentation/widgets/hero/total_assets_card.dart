import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_radius.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/extensions/string_extension.dart';
import 'package:spend_io_app/core/utils/currency_formatter.dart';
import 'package:spend_io_app/core/currency/currency_context.dart';
import 'package:spend_io_app/core/utils/localization.dart';
import 'package:spend_io_app/features/wallet/domain/entities/wallet_summary_entity.dart';

class TotalAssetsCard extends StatefulWidget {
  final WalletSummaryEntity summary;

  const TotalAssetsCard({
    super.key,
    required this.summary,
  });

  @override
  State<TotalAssetsCard> createState() => _TotalAssetsCardState();
}

class _TotalAssetsCardState extends State<TotalAssetsCard> {
  bool _isObscured = false; // Trạng thái ẩn/hiện số dư đồng bộ với Home

  String _formatCurrency(BuildContext context, double amount) {
    final currencyString = formatCurrency(
      amount,
      currencyCode: context.currencyContext.preferredCurrencyCode,
      locale: context.currencyContext.locale,
    );
    return _isObscured ? currencyString.obscure : currencyString;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.translate('total_assets').toUpperCase(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondaryDark,
                      fontWeight: FontWeight.w600,
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
          const SizedBox(height: AppSizes.sm),
          Text(
            _formatCurrency(context, widget.summary.totalAssets),
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: AppColors.textPrimaryDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                ),
          ),
        ],
      ),
    );
  }
}
