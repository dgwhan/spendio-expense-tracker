import 'package:flutter/material.dart';

enum QuickActionType {
  addBudget,
  addAccount,
  addGoal,
  transfer,
}

class QuickActionEntity {
  final String title;

  final IconData icon;

  final QuickActionType type;

  const QuickActionEntity({
    required this.title,
    required this.icon,
    required this.type,
  });
}
