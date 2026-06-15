import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/features/account/presentation/viewmodels/account_details_viewmodel.dart';

Future<void> showAccountDateRangePicker({
  required BuildContext context,
  required AccountDetailsViewModel vm,
}) async {
  final range = await showDateRangePicker(
    context: context,
    firstDate: DateTime(2020),
    lastDate: DateTime.now(),
    initialDateRange: vm.filterState.customDateRange,
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
          ),
        ),
        child: child!,
      );
    },
  );

  if (range != null) {
    vm.setFilter(
      'Custom Range',
      customRange: range,
    );
  }
}
