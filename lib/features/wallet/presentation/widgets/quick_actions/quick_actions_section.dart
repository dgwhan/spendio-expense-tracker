import 'package:flutter/material.dart';
import 'quick_action_card.dart';

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        QuickActionCard(
          icon: Icons.analytics_outlined,
          label: 'Add Budget',
          onTap: () {
            // TODO: Xử lý sự kiện Add Budget
          },
        ),
        QuickActionCard(
          icon: Icons.account_balance_outlined,
          label: 'Add Account',
          onTap: () {
            // TODO: Xử lý sự kiện Add Account
          },
        ),
        QuickActionCard(
          icon: Icons.flag_outlined,
          label: 'Add Goal',
          onTap: () {
            // TODO: Xử lý sự kiện Add Goal
          },
        ),
        QuickActionCard(
          icon: Icons.swap_horiz_outlined,
          label: 'Transfer',
          onTap: () {
            // TODO: Xử lý sự kiện Transfer
          },
        ),
      ],
    );
  }
}
