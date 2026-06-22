import 'package:flutter/material.dart';

class AppTextStyles {
  // ==========================================================================
  // TYPOGRAPHY CHO HỆ THỐNG PHẲNG
  // ==========================================================================

  /// Tiêu đề các Section chính
  static const TextStyle sectionTitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.1,
  );

  /// Tên tiêu đề phụ trong thẻ
  static const TextStyle cardTitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.1,
  );

  /// Số hiển thị số dư lớn, điểm nhấn chính
  static const TextStyle largeAmount = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.3,
  );

  /// Số hiển thị phần trăm hoặc chỉ số tiến độ
  static const TextStyle percentIndicator = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );

  /// Chữ mô tả nhỏ, mờ phụ trợ
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  // ==========================================================================
  // TYPOGRAPHY DÙNG CHUNG TOÀN ỨNG DỤNG
  // ==========================================================================

  /// Tiêu đề cực lớn trên App Bar hoặc màn hình chào mừng
  static const TextStyle displayLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.5,
  );

  /// Tiêu đề tiêu chuẩn của các trang chính hoặc tiêu đề Dialog thông báo
  static const TextStyle headingMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
  );

  /// Nhãn chữ trên các nút bấm lớn
  static const TextStyle buttonLabel = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  /// Đoạn văn bản nội dung thông thường
  static const TextStyle bodyNormal = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.4,
  );

  /// Nhãn phụ cực nhỏ hoặc ngày tháng trong danh sách lịch sử giao dịch
  static const TextStyle overline = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
  );
}
