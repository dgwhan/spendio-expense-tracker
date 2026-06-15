import 'package:flutter/material.dart';
import 'package:spend_io_app/features/account/presentation/viewmodels/account_details_viewmodel.dart';

import 'account_filter_chip.dart';
import 'custom_date_range_bottom_sheet.dart';

class AccountFilterChipBar extends StatelessWidget {
  final AccountDetailsViewModel vm;

  const AccountFilterChipBar({
    super.key,
    required this.vm,
  });

  @override
  Widget build(BuildContext context) {
    final active = vm.filterState.activeRangeLabel;

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildChip(context, 'Today', active),
          _buildChip(context, 'Last 30 Days', active),
          _buildChip(context, 'This Month', active),
          _buildChip(context, 'Last Month', active),
          _buildChip(context, 'This Year', active),
          AccountFilterChip(
            label: 'Custom',
            selected: active == 'Custom Range...',
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => CustomDateRangeBottomSheet(
                  vm: vm,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChip(
    BuildContext context,
    String label,
    String active,
  ) {
    return AccountFilterChip(
      label: label,
      selected: active == label,
      onTap: () {
        vm.setFilter(label);
      },
    );
  }
}
