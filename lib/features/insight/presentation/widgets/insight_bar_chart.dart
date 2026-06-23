import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/utils/currency_formatter.dart';
import 'package:spend_io_app/core/utils/localization.dart';
import 'package:spend_io_app/features/insight/presentation/viewmodels/insight_state.dart';
import 'package:spend_io_app/core/currency/currency_context.dart';

class InsightBarChart extends StatelessWidget {
  final List<BarChartItem> items;

  const InsightBarChart({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor =
        isDark ? AppColors.surfaceSecondaryDark : AppColors.surfaceSecondaryLight;
    final primaryTextColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    if (items.isEmpty) {
      return Container(
        height: 180,
        alignment: Alignment.center,
        child: Text(
          AppLocalizations.translate('no_expenses_period'),
          style: TextStyle(color: secondaryTextColor, fontSize: 13),
        ),
      );
    }

    final double maxValue = items.fold<double>(0, (max, item) {
      return item.value > max ? item.value : max;
    });

    return Card(
      elevation: 0,
      color: cardBgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.translate('spending_trends'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: primaryTextColor,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 180,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: items.map((item) {
                  final double percentage = maxValue == 0 ? 0.0 : item.value / maxValue;

                  return Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (item.value > 0)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6.0),
                            child: Text(
                              CurrencyFormatter.format(
                                item.value,
                                currencyCode: context.currencyContext.preferredCurrencyCode,
                                locale: context.currencyContext.locale,
                              ),
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: primaryTextColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        else
                          const SizedBox(height: 15),
                        Expanded(
                          child: FractionallySizedBox(
                            heightFactor: percentage.clamp(0.04, 1.0),
                            alignment: Alignment.bottomCenter,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeOutCubic,
                              margin: const EdgeInsets.symmetric(horizontal: 6.0),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primary,
                                    AppColors.primary.withValues(alpha: 0.7),
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(6),
                                  topRight: Radius.circular(6),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: secondaryTextColor,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
