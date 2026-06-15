import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/features/account/presentation/viewmodels/account_details_viewmodel.dart';

class CustomDateRangeBottomSheet extends StatefulWidget {
  final AccountDetailsViewModel vm;

  const CustomDateRangeBottomSheet({
    super.key,
    required this.vm,
  });

  @override
  State<CustomDateRangeBottomSheet> createState() =>
      _CustomDateRangeBottomSheetState();
}

class _CustomDateRangeBottomSheetState
    extends State<CustomDateRangeBottomSheet> {
  late DateTime startDate;
  late DateTime endDate;

  @override
  void initState() {
    super.initState();

    final range = widget.vm.filterState.customDateRange;

    startDate =
        range?.start ?? DateTime.now().subtract(const Duration(days: 30));

    endDate = range?.end ?? DateTime.now();
  }

  Future<void> _pickStart() async {
    final date = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() => startDate = date);
    }
  }

  Future<void> _pickEnd() async {
    final date = await showDatePicker(
      context: context,
      initialDate: endDate,
      firstDate: startDate,
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() => endDate = date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Start Date'),
              subtitle: Text(
                DateFormat.yMMMd().format(startDate),
              ),
              trailing: const Icon(Icons.calendar_month),
              onTap: _pickStart,
            ),
            ListTile(
              title: const Text('End Date'),
              subtitle: Text(
                DateFormat.yMMMd().format(endDate),
              ),
              trailing: const Icon(Icons.calendar_month),
              onTap: _pickEnd,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                widget.vm.setFilter(
                  'Custom Range...',
                  customRange: DateTimeRange(
                    start: startDate,
                    end: endDate,
                  ),
                );

                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }
}
