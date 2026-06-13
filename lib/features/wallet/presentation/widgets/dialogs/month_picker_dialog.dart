import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';

class MonthPickerDialog extends StatefulWidget {
  final DateTime initialDate;

  const MonthPickerDialog({
    super.key,
    required this.initialDate,
  });

  @override
  State<MonthPickerDialog> createState() => _MonthPickerDialogState();
}

class _MonthPickerDialogState extends State<MonthPickerDialog> {
  late int _selectedYear;
  late int _selectedMonth;

  final List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialDate.year;
    _selectedMonth = widget.initialDate.month;
  }

  void _previousYear() {
    setState(() {
      _selectedYear--;
    });
  }

  void _nextYear() {
    setState(() {
      _selectedYear++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final titleColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final yearColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final cellBorderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      backgroundColor: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              'Select Month',
              style: TextStyle(
                color: titleColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Year Selector Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _previousYear,
                  icon: Icon(
                    Icons.chevron_left,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(width: 24),
                Text(
                  '$_selectedYear',
                  style: TextStyle(
                    color: yearColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 24),
                IconButton(
                  onPressed: _nextYear,
                  icon: Icon(
                    Icons.chevron_right,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Month Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.8,
              ),
              itemCount: 12,
              itemBuilder: (context, index) {
                final monthNumber = index + 1;
                final isSelected = monthNumber == _selectedMonth && _selectedYear == widget.initialDate.year;
                final monthName = _months[index];

                return InkWell(
                  onTap: () {
                    final selectedDate = DateTime(_selectedYear, monthNumber);
                    Navigator.of(context).pop(selectedDate);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : (isDark ? AppColors.surfaceSecondaryDark : AppColors.surfaceSecondaryLight),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? Colors.transparent : cellBorderColor,
                        width: 1.2,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      monthName,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Cancel Button
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
