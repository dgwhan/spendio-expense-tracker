import 'package:flutter/material.dart';
import 'quick_action_card.dart';

class QuickActionsSection extends StatelessWidget {
  final VoidCallback onAddBudget;
  final VoidCallback onAddAccount;
  final VoidCallback onAddGoal;
  final VoidCallback onTransfer;

  const QuickActionsSection({
    super.key,
    required this.onAddBudget,
    required this.onAddAccount,
    required this.onAddGoal,
    required this.onTransfer,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        QuickActionCard(
          icon: Icons.analytics_outlined,
          label: 'Add Budget',
          onTap: onAddBudget,
        ),
        QuickActionCard(
          icon: Icons.account_balance_outlined,
          label: 'Add Account',
          onTap: onAddAccount,
        ),
        QuickActionCard(
          icon: Icons.flag_outlined,
          label: 'Add Goal',
          onTap: onAddGoal,
        ),
        QuickActionCard(
          icon: Icons.swap_horiz_outlined,
          label: 'Transfer',
          onTap: onTransfer,
        ),
      ],
    );
  }
}
