import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_radius.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/features/account/presentation/viewmodels/account_details_viewmodel.dart';

/// [App Location] Account Details Screen -> Modal Bottom Sheet.
/// [Core Function] Overlay selector sheet managing quick financial date range presets and custom range triggers.
class AccountFilterBottomSheet extends StatelessWidget {
  final AccountDetailsViewModel detailsVM;

  const AccountFilterBottomSheet({super.key, required this.detailsVM});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final backgroundColor =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppRadius.cardRadiusLg),
          topRight: Radius.circular(AppRadius.cardRadiusLg),
        ),
      ),
      padding: const EdgeInsets.all(AppSizes.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Active Range',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryTextColor,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.5,
            children: [
              _buildOption(context, 'Last 30 Days'),
              _buildOption(context, 'Today'),
              _buildOption(context, 'This Month'),
              _buildOption(context, 'Last Month'),
              _buildOption(context, 'This Year'),
              _buildOption(context, 'Custom Range...', isCustom: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOption(BuildContext context, String label,
      {bool isCustom = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = AppColors.primary;
    final inactiveColor = isDark
        ? AppColors.surfaceSecondaryDark
        : AppColors.surfaceSecondaryLight;
    final isSelected = detailsVM.filterState.activeRangeLabel == label;

    return InkWell(
      onTap: () async {
        Navigator.pop(context);

        if (isCustom) {
          final DateTimeRange? range = await showDateRangePicker(
            context: context,
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
            initialDateRange: detailsVM.filterState.customDateRange,
            builder: (context, child) => Theme(
              data: Theme.of(context).copyWith(
                colorScheme: Theme.of(context)
                    .colorScheme
                    .copyWith(primary: AppColors.primary),
              ),
              child: child!,
            ),
          );
          if (range != null) {
            detailsVM.setFilter('Custom Range...', customRange: range);
          }
        } else {
          detailsVM.setFilter(label);
        }
      },
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        decoration: BoxDecoration(
          color:
              isSelected ? activeColor.withValues(alpha: 0.15) : inactiveColor,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? activeColor : AppColors.transparent,
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected
                ? activeColor
                : (isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight),
          ),
        ),
      ),
    );
  }
}
