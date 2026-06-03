import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/features/dashboard/models/dashboard_summary_model.dart';

class BalanceSummaryCard extends StatelessWidget {
  final DashboardSummaryModel summary;

  const BalanceSummaryCard({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}

class _StatItem extends StatelessWidget {
  final String title;
  final double amount;

  const _StatItem({
    required this.title,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
