import 'package:flutter/material.dart';
import 'package:spend_io_app/features/account/presentation/viewmodels/account_details_viewmodel.dart';
import 'package:spend_io_app/features/account/presentation/widgets/filter/account_filter_date_picker.dart';

Future<void> showAccountFilterMenu({
  required BuildContext context,
  required AccountDetailsViewModel vm,
}) async {
  final selected = await showMenu<String>(
    context: context,
    position: const RelativeRect.fromLTRB(
      100,
      120,
      20,
      0,
    ),
    items: [
      _item('Today'),
      _item('Last 7 Days'),
      _item('Last 30 Days'),
      _item('This Month'),
      _item('Last Month'),
      _item('This Year'),
      const PopupMenuDivider(),
      _item(
        'Custom Range',
        icon: Icons.date_range_rounded,
      ),
    ],
  );

  if (selected == null) return;

  if (selected == 'Custom Range') {
    await showAccountDateRangePicker(
      context: context,
      vm: vm,
    );
    return;
  }

  vm.setFilter(selected);
}

PopupMenuItem<String> _item(
  String value, {
  IconData? icon,
}) {
  return PopupMenuItem<String>(
    value: value,
    child: Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18),
          const SizedBox(width: 10),
        ],
        Text(value),
      ],
    ),
  );
}
