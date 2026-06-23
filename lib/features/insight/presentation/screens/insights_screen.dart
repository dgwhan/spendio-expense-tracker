import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/utils/currency_formatter.dart';
import 'package:spend_io_app/core/currency/currency_context.dart';
import 'package:spend_io_app/core/utils/localization.dart';
import 'package:spend_io_app/features/category/presentation/viewmodels/category_viewmodel.dart';
import 'package:spend_io_app/features/transaction/presentation/viewmodels/transaction_viewmodel.dart';
import 'package:spend_io_app/features/insight/presentation/viewmodels/insight_viewmodel.dart';
import 'package:spend_io_app/features/insight/presentation/widgets/insight_bar_chart.dart';
import 'package:spend_io_app/shared/charts/donut_chart.dart';
import 'package:spend_io_app/core/widgets/app_header.dart';
import 'package:spend_io_app/shared/widgets/date_picker/app_custome_date_picker_sheet.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  String _getFilterTitle(String activeFilter) {
    switch (activeFilter) {
      case 'Day':
        return AppLocalizations.translate('today').toUpperCase();
      case 'Year':
        return AppLocalizations.translate('this_year').toUpperCase();
      case 'Custom':
        return AppLocalizations.translate('custom_range').toUpperCase();
      case 'Month':
      default:
        return AppLocalizations.translate('this_month').toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final cardBgColor =
        isDark ? AppColors.surfaceSecondaryDark : AppColors.surfaceSecondaryLight;
    final primaryTextColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    final txVM = context.watch<TransactionViewModel>();
    final categoryVM = context.watch<CategoryViewModel>();
    final insightVM = context.watch<InsightViewModel>();

    // Calculate state reactively from viewmodel using data sources
    final state = insightVM.getCalculatedState(
      context,
      txVM.state.transactions,
      categoryVM.state.categories,
    );

    // Map spending items to donut sections
    final List<DonutSectionData> donutSections = state.spendingItems.map((item) {
      return DonutSectionData(
        value: item.percentage,
        color: item.color,
      );
    }).toList();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppHeader(
        title: AppLocalizations.translate('insights'),
        showBack: false,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            await txVM.loadAllTransactions();
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              // ================= FILTER SEGMENT =================
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverToBoxAdapter(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip(context, insightVM, 'Day'),
                        const SizedBox(width: 8),
                        _buildFilterChip(context, insightVM, 'Month'),
                        const SizedBox(width: 8),
                        _buildFilterChip(context, insightVM, 'Year'),
                        const SizedBox(width: 8),
                        _buildFilterChip(context, insightVM, 'Custom'),
                      ],
                    ),
                  ),
                ),
              ),

              // ================= INCOME & EXPENSE SUMMARY CARD =================
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                sliver: SliverToBoxAdapter(
                  child: Card(
                    elevation: 0,
                    color: cardBgColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppLocalizations.translate('net_flow_balance'),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: secondaryTextColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                formatCurrency(
                                  state.netBalance,
                                  currencyCode: context.currencyContext.preferredCurrencyCode,
                                  locale: context.currencyContext.locale,
                                ),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: state.netBalance >= 0 ? AppColors.success : AppColors.error,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(height: 1),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildFlowSummary(
                                  context: context,
                                  title: AppLocalizations.translate('income'),
                                  amount: state.totalIncome,
                                  color: AppColors.success,
                                  icon: Icons.arrow_downward_rounded,
                                  isDark: isDark,
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: isDark ? Colors.grey[850] : Colors.grey[200],
                              ),
                              Expanded(
                                child: _buildFlowSummary(
                                  context: context,
                                  title: AppLocalizations.translate('expense'),
                                  amount: state.totalExpense,
                                  color: AppColors.error,
                                  icon: Icons.arrow_upward_rounded,
                                  isDark: isDark,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ================= VISUAL CHART AREA =================
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      Card(
                        elevation: 0,
                        color: cardBgColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: state.spendingItems.isEmpty
                              ? SizedBox(
                                  height: 180,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.pie_chart_outline_rounded,
                                          size: 48,
                                          color: isDark ? Colors.grey[700] : Colors.grey[300],
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          AppLocalizations.translate('no_expenses_period'),
                                          style: TextStyle(
                                            color: secondaryTextColor,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : Column(
                                  children: [
                                    SizedBox(
                                      height: 200,
                                      width: 200,
                                      child: DonutChart(
                                        sections: donutSections,
                                        strokeWidth: 16,
                                        centerWidget: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              _getFilterTitle(state.activeFilter),
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: secondaryTextColor,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              CurrencyFormatter.format(
                                                state.totalExpense,
                                                currencyCode: context.currencyContext.preferredCurrencyCode,
                                                locale: context.currencyContext.locale,
                                              ),
                                              style: TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.w800,
                                                color: primaryTextColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      if (state.spendingItems.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        InsightBarChart(items: state.barItems),
                      ],
                    ],
                  ),
                ),
              ),

              // ================= DETAILED BREAKDOWN LIST =================
              if (state.spendingItems.isNotEmpty) ...[
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      AppLocalizations.translate('spending_details'),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: primaryTextColor,
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 40.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = state.spendingItems[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Card(
                            elevation: 0,
                            color: cardBgColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: item.color.withValues(alpha: 0.12),
                                child: Icon(
                                  IconData(
                                    item.iconCodePoint,
                                    fontFamily: item.iconFontFamily ?? 'MaterialIcons',
                                  ),
                                  color: item.color,
                                  size: 18,
                                ),
                              ),
                              title: Text(
                                item.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: primaryTextColor,
                                ),
                              ),
                              subtitle: Text(
                                '${(item.percentage * 100).toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: secondaryTextColor,
                                ),
                              ),
                              trailing: Text(
                                formatCurrency(
                                  item.amount,
                                  currencyCode: context.currencyContext.preferredCurrencyCode,
                                  locale: context.currencyContext.locale,
                                ),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: primaryTextColor,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: state.spendingItems.length,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, InsightViewModel insightVM, String filter) {
    final isSelected = insightVM.activeFilter == filter;
    
    String labelText;
    if (filter == 'Day') {
      labelText = AppLocalizations.translate('today');
    } else if (filter == 'Month') {
      labelText = AppLocalizations.translate('this_month');
    } else if (filter == 'Year') {
      labelText = AppLocalizations.translate('this_year');
    } else {
      final range = insightVM.customRange;
      if (range != null) {
        labelText = "${range.start.day}/${range.start.month} - ${range.end.day}/${range.end.month}";
      } else {
        labelText = AppLocalizations.translate('custom_range');
      }
    }

    return ChoiceChip(
      label: Text(labelText),
      selected: isSelected,
      selectedColor: AppColors.primary.withValues(alpha: 0.15),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : Colors.grey,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 13,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      onSelected: (_) async {
        if (filter == 'Custom') {
          final returnedRange = await showModalBottomSheet<DateTimeRange>(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => AppCustomeDatePickerSheet(initialRange: insightVM.customRange),
          );
          if (returnedRange != null) {
            insightVM.changeFilter('Custom', range: returnedRange);
          }
        } else {
          insightVM.changeFilter(filter);
        }
      },
    );
  }

  Widget _buildFlowSummary({
    required BuildContext context,
    required String title,
    required double amount,
    required Color color,
    required IconData icon,
    required bool isDark,
  }) {
    final secondaryTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final primaryTextColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(icon, color: color, size: 14),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 10,
                color: secondaryTextColor,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            Text(
                                              CurrencyFormatter.format(
                                                amount,
                                                currencyCode: context.currencyContext.preferredCurrencyCode,
                                                locale: context.currencyContext.locale,
                                              ),
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: primaryTextColor,
                                              ),
            ),
          ],
        ),
      ],
    );
  }
}
