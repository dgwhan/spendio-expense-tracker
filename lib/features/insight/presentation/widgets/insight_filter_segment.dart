import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_radius.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/constants/app_text_styles.dart';
import 'package:spend_io_app/core/utils/localization.dart';
import 'package:spend_io_app/features/insight/presentation/viewmodels/insight_viewmodel.dart';
import 'package:spend_io_app/shared/widgets/date_picker/app_custome_date_picker_sheet.dart';

class InsightFilterSegment extends StatelessWidget {
  final InsightViewModel insightVM;

  const InsightFilterSegment({super.key, required this.insightVM});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unselectedBg = isDark ? AppColors.surfaceDark : const Color(0xFFF4F5F7);
    final selectedBg = isDark ? AppColors.primary : const Color(0xFF0046E5);

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: 8),
      sliver: SliverToBoxAdapter(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: ['Day', 'Month', 'Year', 'Custom'].map((filter) {
              final isSelected = insightVM.activeFilter == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text(_getLabelText(filter)),
                  ),
                  selected: isSelected,
                  onSelected: (_) => _onFilterSelected(context, filter),
                  backgroundColor: unselectedBg,
                  selectedColor: selectedBg,
                  elevation: 0,
                  pressElevation: 0,
                  shadowColor: Colors.transparent,
                  selectedShadowColor: Colors.transparent,
                  labelStyle: AppTextStyles.buttonLabel.copyWith(
                    fontSize: 12,
                    color: isSelected
                        ? Colors.white
                        : (isDark
                            ? AppColors.textSecondaryDark
                            : const Color(0xFF4A5568)),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    side: const BorderSide(
                        color: Colors.transparent, width: 0, style: BorderStyle.none),
                  ),
                  showCheckmark: false,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  String _getLabelText(String filter) {
    if (filter == 'Day') return AppLocalizations.translate('today');
    if (filter == 'Month') return AppLocalizations.translate('this_month');
    if (filter == 'Year') return AppLocalizations.translate('this_year');

    final range = insightVM.customRange;
    if (range != null) {
      return "${range.start.day}/${range.start.month} - ${range.end.day}/${range.end.month}";
    }
    return AppLocalizations.translate('custom_range');
  }

  void _onFilterSelected(BuildContext context, String filter) async {
    if (filter == 'Custom') {
      final returnedRange = await showModalBottomSheet<DateTimeRange>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) =>
            AppCustomeDatePickerSheet(initialRange: insightVM.customRange),
      );
      if (returnedRange != null) {
        insightVM.changeFilter('Custom', range: returnedRange);
      }
    } else {
      insightVM.changeFilter(filter);
    }
  }
}
