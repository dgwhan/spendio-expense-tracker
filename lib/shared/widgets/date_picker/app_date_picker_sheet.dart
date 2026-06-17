import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_radius.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';

class AppDatePickerSheet extends StatefulWidget {
  final DateTimeRange? initialRange;
  final bool
      isSingleDateMode; // 🌟 true nếu chỉ chọn 1 ngày (Thêm/Sửa), false nếu chọn khoảng ngày (Bộ lọc)
  final DateTime?
      maxDate; // 🌟 Cho phép truyền ngày tối đa từ bên ngoài để chặn tương lai

  const AppDatePickerSheet({
    super.key,
    this.initialRange,
    this.isSingleDateMode = false,
    this.maxDate,
  });

  @override
  State<AppDatePickerSheet> createState() => _AppDatePickerSheetState();
}

class _AppDatePickerSheetState extends State<AppDatePickerSheet> {
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  DateTime? _selectedSingleDate;

  @override
  void initState() {
    super.initState();
    if (widget.initialRange != null) {
      _rangeStart = widget.initialRange!.start;
      _rangeEnd = widget.initialRange!.end;
      _selectedSingleDate = widget.initialRange!.start;
      _focusedDay = widget.initialRange!.start;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final surfaceColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final primaryTextColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedTextColor =
        isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // Xác định ngày cuối cùng được phép hiển thị trên lịch (Mặc định năm 2040)
    final DateTime calendarLastDay = widget.maxDate ?? DateTime(2040);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppRadius.cardRadiusLg),
          topRight: Radius.circular(AppRadius.cardRadiusLg),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
          AppSizes.lg, AppSizes.md, AppSizes.lg, AppSizes.md + bottomPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle Bar thanh lịch
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: (isDark ? AppColors.borderDark : AppColors.borderLight)
                  .withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppSizes.md),

          // Header Tiêu đề
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.isSingleDateMode ? 'Select Date' : 'Select Custom Range',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor),
              ),
              if (!widget.isSingleDateMode && _rangeStart != null)
                Text(
                  _rangeEnd == null
                      ? 'Select end date'
                      : '${_rangeStart!.day}/${_rangeStart!.month} - ${_rangeEnd!.day}/${_rangeEnd!.month}',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary),
                ),
              if (widget.isSingleDateMode && _selectedSingleDate != null)
                Text(
                  '${_selectedSingleDate!.day}/${_selectedSingleDate!.month}/${_selectedSingleDate!.year}',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary),
                ),
            ],
          ),
          const SizedBox(height: AppSizes.md),

          // Bộ Lịch
          Container(
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight),
            ),
            child: TableCalendar(
              firstDay: DateTime(2020),
              lastDay: calendarLastDay,
              focusedDay: _focusedDay.isAfter(calendarLastDay)
                  ? calendarLastDay
                  : _focusedDay,
              calendarFormat: _calendarFormat,
              startingDayOfWeek: StartingDayOfWeek.monday,
              headerStyle: HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
                titleTextStyle: TextStyle(
                    color: primaryTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
                leftChevronIcon:
                    Icon(Icons.chevron_left_rounded, color: primaryTextColor),
                rightChevronIcon:
                    Icon(Icons.chevron_right_rounded, color: primaryTextColor),
              ),
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                defaultTextStyle:
                    TextStyle(color: primaryTextColor, fontSize: 13),
                weekendTextStyle:
                    TextStyle(color: mutedTextColor, fontSize: 13),
                rangeStartDecoration: const BoxDecoration(
                    color: AppColors.primary, shape: BoxShape.circle),
                rangeEndDecoration: const BoxDecoration(
                    color: AppColors.primary, shape: BoxShape.circle),
                rangeHighlightColor: AppColors.primary.withValues(alpha: 0.12),
                withinRangeTextStyle: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13),
                selectedDecoration: const BoxDecoration(
                    color: AppColors.primary, shape: BoxShape.circle),
                todayDecoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary, width: 1),
                  shape: BoxShape.circle,
                ),
                todayTextStyle: const TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
              rangeSelectionMode: widget.isSingleDateMode
                  ? RangeSelectionMode.disabled
                  : RangeSelectionMode.enforced,
              rangeStartDay: widget.isSingleDateMode ? null : _rangeStart,
              rangeEndDay: widget.isSingleDateMode ? null : _rangeEnd,
              selectedDayPredicate: (day) => widget.isSingleDateMode
                  ? isSameDay(_selectedSingleDate, day)
                  : false,
              onDaySelected: (selectedDay, focusedDay) {
                if (widget.isSingleDateMode) {
                  setState(() {
                    _selectedSingleDate = selectedDay;
                    _focusedDay = focusedDay;
                  });
                }
              },
              onRangeSelected: (start, end, focusedDay) {
                if (!widget.isSingleDateMode) {
                  setState(() {
                    _rangeStart = start;
                    _rangeEnd = end;
                    _focusedDay = focusedDay;
                  });
                }
              },
              onPageChanged: (focusedDay) => _focusedDay = focusedDay,
            ),
          ),
          const SizedBox(height: AppSizes.lg),

          // Hệ thống Nút bấm
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md)),
                    side: BorderSide(
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight),
                  ),
                  child:
                      Text('Cancel', style: TextStyle(color: mutedTextColor)),
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (widget.isSingleDateMode) {
                      if (_selectedSingleDate != null) {
                        // 🌟 TỰ ĐỘNG BỐC GIỜ HIỆN TẠI CỦA HỆ THỐNG NÈ MÁ:
                        final now = DateTime.now();
                        final gopNgayGio = DateTime(
                          _selectedSingleDate!.year,
                          _selectedSingleDate!.month,
                          _selectedSingleDate!.day,
                          now.hour, // Giờ hệ thống
                          now.minute, // Phút hệ thống
                          now.second, // Giây hệ thống luôn cho chắc bài
                        );

                        // Trả về dải trùng nhau chứa cả ngày đã chọn lẫn giờ hệ thống mượt mà
                        Navigator.pop(context,
                            DateTimeRange(start: gopNgayGio, end: gopNgayGio));
                      }
                    } else {
                      if (_rangeStart != null && _rangeEnd != null) {
                        Navigator.pop(
                            context,
                            DateTimeRange(
                                start: _rangeStart!, end: _rangeEnd!));
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md)),
                    elevation: 0,
                  ),
                  child: const Text('Apply Filter',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
