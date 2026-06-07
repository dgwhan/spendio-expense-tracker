import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';

// Định nghĩa cấu trúc dữ liệu cho các mục thông tin nhỏ phía dưới
class SummaryItem {
  final String label;
  final String value;
  final Color? valueColor;

  SummaryItem({
    required this.label,
    required this.value,
    this.valueColor,
  });
}

class SummaryCard extends StatelessWidget {
  final String title;
  final String mainBalance;
  final List<SummaryItem> items;
  final String? statusLabel;
  final Widget? trailingIcon;

  const SummaryCard({
    Key? key,
    required this.title,
    required this.mainBalance,
    required this.items,
    this.statusLabel,
    this.trailingIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Kiểm tra chế độ Dark Mode của hệ thống để linh hoạt thay đổi màu chữ/nền mờ khi cần
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.0),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.gradientStart,
            AppColors.gradientEnd,
          ],
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          //hàng Tiêu đề và trạng thái
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  color: (isDarkMode
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight)
                      .withValues(alpha: 0.8),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              if (statusLabel != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Excellent',
                        style: TextStyle(
                          color: AppColors.textPrimaryLight,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              else if (trailingIcon != null)
                trailingIcon!,
            ],
          ),
          const SizedBox(height: 12),

          //số dư chính
          Text(
            mainBalance,
            style: TextStyle(
              color: isDarkMode ? AppColors.textPrimaryDark : Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),

          //đường kẻ ngang mờ phân cách
          Container(
            height: 1,
            color: (isDarkMode ? AppColors.dividerDark : AppColors.dividerLight)
                .withValues(alpha: 0.2),
          ),
          const SizedBox(height: 20),

          //hàng hiển thị danh sách các thông số động
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items.map((item) {
              return Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.label.toUpperCase(),
                      style: TextStyle(
                        color: (isDarkMode
                                ? AppColors.textMutedDark
                                : AppColors.textMutedLight)
                            .withValues(alpha: 0.9),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.value,
                      style: TextStyle(
                        color: item.valueColor ??
                            (isDarkMode
                                ? AppColors.textPrimaryDark
                                : Colors.white),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
