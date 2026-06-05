import 'dart:math';
import 'package:flutter/material.dart';
import 'package:spend_io_app/features/dashboard/datasource/models/spending_breakdown_model.dart';
import 'package:spend_io_app/features/dashboard/presentation/widgets/spending_breakdown/helpers/breakdown_color_helper.dart';
import 'breakdown_center_info.dart';

class BreakdownChart extends StatelessWidget {
  final SpendingBreakdownModel data;

  const BreakdownChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 180,
          height: 180,
          child: CustomPaint(
            painter: DonutChartPainter(items: data.items),
          ),
        ),
        BreakdownCenterInfo(
          title: data.periodTitle,
          totalAmount: data.totalAmount,
        ),
      ],
    );
  }
}

class DonutChartPainter extends CustomPainter {
  final List<SpendingItemModel> items;

  DonutChartPainter({required this.items});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2) - 8;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    double startAngle = -pi / 2;

    for (var item in items) {
      final sweepAngle = item.percentage * 2 * pi;
      paint.color = BreakdownColorHelper.getColor(item.name);

      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
