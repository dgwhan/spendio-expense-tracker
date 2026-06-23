import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/currency/currency_context.dart';
import 'package:spend_io_app/core/utils/currency_formatter.dart';
import 'package:spend_io_app/core/utils/localization.dart';
import 'package:spend_io_app/features/insight/presentation/viewmodels/insight_state.dart';

class InsightBarChart extends StatelessWidget {
  final List<BarChartItem> items;

  const InsightBarChart({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryTextColor = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;

    if (items.isEmpty) {
      return Container(
        height: 240,
        alignment: Alignment.center,
        child: Text(
          AppLocalizations.translate('no_expenses_period'),
          style: TextStyle(
            color: secondaryTextColor,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    final maxValue = items.fold<double>(
      0,
      (max, item) => item.value > max ? item.value : max,
    );

    final highestValue = items.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    // Tính toán độ dày của cột dựa trên tổng số lượng cột (Responsive)
    final double barWidth;
    final double activeBarWidth;
    if (items.length > 20) {
      barWidth = 6.0;
      activeBarWidth = 10.0;
    } else if (items.length > 10) {
      barWidth = 12.0;
      activeBarWidth = 16.0;
    } else {
      barWidth = 20.0;
      activeBarWidth = 26.0;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                AppLocalizations.translate('spending_trends'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                  color: primaryTextColor,
                ),
              ),
            ),
            if (maxValue > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  CurrencyFormatter.format(
                    maxValue,
                    currencyCode: context.currencyContext.preferredCurrencyCode,
                    locale: context.currencyContext.locale,
                  ),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 220,
          child: Stack(
            children: [
              // 1. Đường lưới ngang mờ (Subtle horizontal grid lines)
              Positioned.fill(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    5,
                    (_) => Divider(
                      height: 1,
                      thickness: 0.5,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.black.withValues(alpha: 0.05),
                    ),
                  ),
                ),
              ),

              // 2. Các cột biểu đồ xu hướng chi tiêu
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(
                  items.length,
                  (index) {
                    final item = items[index];
                    final percentage = maxValue == 0 ? 0.0 : item.value / maxValue;
                    final isHighest = item.value == highestValue && highestValue > 0;

                    // Chỉ hiển thị nhãn chọn lọc nếu số cột quá lớn để chống chen chúc nhãn
                    final showLabel = items.length <= 12 ||
                        index == 0 ||
                        index == items.length ~/ 4 ||
                        index == items.length ~/ 2 ||
                        index == (items.length * 3 ~/ 4) ||
                        index == items.length - 1;

                    final formattedValue = CurrencyFormatter.format(
                      item.value,
                      currencyCode: context.currencyContext.preferredCurrencyCode,
                      locale: context.currencyContext.locale,
                    );

                    return Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Top Value Badge tinh tế cho cột cao nhất (không icon, nhãn mờ nhã nhặn)
                          Container(
                            height: 24,
                            alignment: Alignment.bottomCenter,
                            child: isHighest && item.value > 0
                                ? Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      formattedValue,
                                      style: const TextStyle(
                                        fontSize: 8,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primary,
                                      ),
                                      maxLines: 1,
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                          const SizedBox(height: 4),

                          // Cột thực tế
                          Expanded(
                            child: Tooltip(
                              message: "${item.label}: $formattedValue",
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E222B) : Colors.black,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              textStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                  fontWeight: FontWeight.w600,
                              ),
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeOutCubic,
                                  width: isHighest ? activeBarWidth : barWidth,
                                  height: (percentage * 140).clamp(4.0, 140.0),
                                  decoration: BoxDecoration(
                                    color: isHighest
                                        ? AppColors.primary
                                        : AppColors.primary.withValues(alpha: 0.3),
                                    boxShadow: isHighest
                                        ? [
                                            BoxShadow(
                                              color: AppColors.primary.withValues(alpha: 0.2),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            )
                                          ]
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Nhãn thời gian
                          SizedBox(
                            height: 16,
                            child: Text(
                              showLabel ? item.label : '',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: secondaryTextColor,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}