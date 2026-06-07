import 'package:flutter/material.dart';
import 'package:spend_io_app/features/home/presentation/widgets/savings_goal/helpers/goal_style_helper.dart';

class GoalStatusBadge extends StatelessWidget {
  final String status;

  const GoalStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final colors = GoalStyleHelper.getStatusColors(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colors['bg'],
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: colors['text'],
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
