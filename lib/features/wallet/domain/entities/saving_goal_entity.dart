import 'package:flutter/material.dart';

class SavingGoalEntity {
  final String name;

  final double currentAmount;
  final double targetAmount;

  final DateTime estimatedDate;

  final IconData icon;

  const SavingGoalEntity({
    required this.name,
    required this.currentAmount,
    required this.targetAmount,
    required this.estimatedDate,
    required this.icon,
  });
}
