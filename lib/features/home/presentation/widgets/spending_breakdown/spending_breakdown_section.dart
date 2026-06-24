import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/features/home/data/models/spending_breakdown_model.dart';
import 'package:spend_io_app/features/home/presentation/widgets/home_section_container.dart';
import 'package:spend_io_app/core/widgets/button/app_text_button.dart';

import 'widgets/breakdown_filter_tabs.dart';
import 'widgets/breakdown_chart.dart';
import 'widgets/breakdown_legend.dart';

class SpendingBreakdownSection extends StatefulWidget {
  final SpendingBreakdownModel weekData;
  final SpendingBreakdownModel monthData;
  final SpendingBreakdownModel yearData;
  final VoidCallback? onViewDetailTap;
  final VoidCallback? onViewMoreTap;

  const SpendingBreakdownSection({
    super.key,
    required this.weekData,
    required this.monthData,
    required this.yearData,
    this.onViewDetailTap,
    this.onViewMoreTap,
  });

  @override
  State<SpendingBreakdownSection> createState() =>
      _SpendingBreakdownSectionState();
}

class _SpendingBreakdownSectionState extends State<SpendingBreakdownSection> {
  String _activeTab =
      'Month'; // Mặc định mở app lên chọn tab Month cho chuẩn UI mẫu

  // LOGIC ĐỘNG: Hàm Helper tự động bốc đúng tập dữ liệu dựa trên tab đang kích hoạt
  SpendingBreakdownModel get _currentBreakdownData {
    switch (_activeTab) {
      case 'Week':
        return widget.weekData;
      case 'Year':
        return widget.yearData;
      case 'Month':
      default:
        return widget.monthData;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lấy dữ liệu đã được lọc tự động để render ra dữ liệu
    final activeData = _currentBreakdownData;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Spending Breakdown',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryLight,
                    ),
              ),
              AppTextButton(
                text: 'View Detail',
                fontSize: 13,
                onTap: widget.onViewDetailTap,
              ),
            ],
          ),
        ),
        HomeSectionContainer(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              //thanh Tab chuyển đổi trạng thái
              BreakdownFilterTabs(
                activeTab: _activeTab,
                onTabChanged: (tab) {
                  setState(() {
                    _activeTab = tab;
                  });
                },
              ),
              const SizedBox(height: 24),

              //biểu đồ vẽ lại các cung màu động theo dữ liệu mới
              BreakdownChart(data: activeData),
              const SizedBox(height: 24),

              //danh sách chú thích tự động cập nhật số tiền rút gọn và % tương ứng
              BreakdownLegend(
                items: activeData.items,
                onViewMoreTap: widget.onViewMoreTap,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
