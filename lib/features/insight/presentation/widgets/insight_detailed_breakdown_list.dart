import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/constants/app_text_styles.dart';
import 'package:spend_io_app/core/currency/currency_context.dart';
import 'package:spend_io_app/core/utils/currency_formatter.dart';
import 'package:spend_io_app/core/utils/localization.dart';
import 'package:spend_io_app/features/insight/presentation/viewmodels/insight_state.dart';

class InsightDetailedBreakdownList extends StatelessWidget {
  final InsightState state;

  const InsightDetailedBreakdownList({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.spendingItems.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.surfaceDark : Colors.white;
    final primaryTextColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedTextColor =
        isDark ? AppColors.textMutedDark : AppColors.textMutedLight;



    return MultiSliver(
      children: [
        // --- TIÊU ĐỀ CATEGORY ANALYSIS ---
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
              AppSizes.md, AppSizes.md, AppSizes.md, AppSizes.xs),
          sliver: SliverToBoxAdapter(
            child: Text(
              AppLocalizations.translate('spending_details'),
              style: AppTextStyles.sectionTitle.copyWith(
                color: primaryTextColor,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ),

        // --- DANH SÁCH DANH MỤC PHÂN TÍCH (Bo góc 24px, Premium Card) ---
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(AppSizes.md, AppSizes.xs, AppSizes.md, 40.0),
          sliver: SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(24.0),
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        )
                      ],
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  width: 1,
                ),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.spendingItems.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  thickness: 1,
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  indent: 64,
                  endIndent: 16,
                ),
                itemBuilder: (context, index) {
                  final item = state.spendingItems[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 2),
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: item.color.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          IconData(
                            item.iconCodePoint,
                            fontFamily: item.iconFontFamily ?? 'MaterialIcons',
                          ),
                          color: item.color,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        item.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: primaryTextColor,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: SizedBox(
                            height: 6,
                            child: LinearProgressIndicator(
                              value: item.percentage,
                              backgroundColor: isDark
                                  ? const Color(0xFF1E222B)
                                  : const Color(0xFFF1F3F5),
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(item.color),
                            ),
                          ),
                        ),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            formatCurrency(
                              item.amount,
                              currencyCode:
                                  context.currencyContext.preferredCurrencyCode,
                              locale: context.currencyContext.locale,
                            ),
                            style: TextStyle(
                              fontSize: 14,
                              color: primaryTextColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${(item.percentage * 100).toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: mutedTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class MultiSliver extends StatelessWidget {
  final List<Widget> children;
  const MultiSliver({super.key, required this.children});
  @override
  Widget build(BuildContext context) => SliverMainAxisGroup(slivers: children);
}
