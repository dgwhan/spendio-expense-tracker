import 'package:flutter/material.dart';
import 'package:spend_io_app/features/dashboard/presentation/widgets/savings_goal/helpers/goal_style_helper.dart';

class GoalIcon extends StatelessWidget {
  final String iconType;

  const GoalIcon({super.key, required this.iconType});

  @override
  Widget build(BuildContext context) {
    final style = GoalStyleHelper.getIconStyle(iconType);

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: style['bgColor'],
        shape: BoxShape.circle,
      ),
      child: Icon(
        style['icon'],
        color: style['color'],
        size: 22,
      ),
    );
  }
}
