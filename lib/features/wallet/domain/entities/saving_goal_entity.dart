import 'package:flutter/material.dart';

class SavingGoalEntity {
  final String id;

  final String name;

  final double currentAmount;

  final double targetAmount;

  final DateTime estimatedDate;

  final IconData icon;

  const SavingGoalEntity({
    required this.id,
    required this.name,
    required this.currentAmount,
    required this.targetAmount,
    required this.estimatedDate,
    required this.icon,
  });

  double get progress {
    if (targetAmount == 0) return 0;

    return currentAmount / targetAmount;
  }
}
