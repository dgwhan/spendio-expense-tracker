import 'dart:math' as math;
import 'package:flutter/material.dart';

class DonutSectionData {
  final double value;
  final Color color;

  DonutSectionData({
    required this.value,
    required this.color,
  });
}

class DonutChart extends StatelessWidget {
  final List<DonutSectionData> sections;
  final double strokeWidth;
  final Widget centerWidget;

  const DonutChart({
    super.key,
    required this.sections,
    this.strokeWidth = 12.0,
    required this.centerWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Khối vẽ Chart thuần bằng CustomPaint
        AspectRatio(
          aspectRatio: 1,
          child: CustomPaint(
            painter: _DonutChartPainter(
              sections: sections,
              strokeWidth: strokeWidth,
            ),
          ),
        ),
        // Nội dung chữ ở giữa tâm
        Positioned.fill(
          child: Align(
            alignment: Alignment.center,
            child: centerWidget,
          ),
        ),
      ],
    );
  }
}

// Lớp xử lý kỹ thuật vẽ đồ họa nền tảng bằng Canvas
class _DonutChartPainter extends CustomPainter {
  final List<DonutSectionData> sections;
  final double strokeWidth;

  _DonutChartPainter({
    required this.sections,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double total = sections.fold(0, (sum, item) => sum + item.value);
    if (total == 0) return;

    final double radius = (size.width - strokeWidth) / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final Rect rect = Rect.fromCircle(center: center, radius: radius);

    // Bắt đầu vẽ từ đỉnh 12 giờ (-90 độ hay -pi/2 radian)
    double startAngle = -math.pi / 2;
    // Tạo khoảng cách hở nhỏ giữa các phần (tương đương 2 độ)
    const double gapAngle = 2 * math.pi / 360;

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round; // Bo tròn 2 đầu mút giống hệt thiết kế

    for (var section in sections) {
      if (section.value == 0) continue;

      // Tính góc quét của phần hiện tại dựa trên tỷ lệ phần trăm
      final double sweepAngle = (section.value / total) * 2 * math.pi;

      // Trừ bớt khoảng hở để các đoạn không dính liền vào nhau
      final double adjustedSweep = sweepAngle - gapAngle;

      if (adjustedSweep > 0) {
        paint.color = section.color;
        canvas.drawArc(rect, startAngle, adjustedSweep, false, paint);
      }

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.sections != sections ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
