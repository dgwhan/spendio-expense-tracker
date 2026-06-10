import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/features/wallet/data/datasource/wallet_local_data_source.dart';
import 'package:spend_io_app/shared/widgets/buttons/app_text_button.dart';
import 'saving_goal_card.dart';

class GoalsSection extends StatelessWidget {
  const GoalsSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy dữ liệu goals giả lập từ WalletLocalDataSource của bạn
    final liveGoals = WalletLocalDataSource.goals;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Phần Header của mục Savings Goals
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Savings Goals',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryLight,
              ),
            ),
            AppTextButton(
              text: 'Add',
              fontWeight: FontWeight.bold,
              fontSize: 16,
              onTap: () {
                // TODO: Xử lý thêm mục tiêu tiết kiệm mới
              },
            ),
          ],
        ),
        const SizedBox(height: AppSizes.md),

        // Danh sách các thẻ mục tiêu lặp qua liveGoals
        ...liveGoals.map((goal) => SavingGoalCard(goal: goal)),
      ],
    );
  }
}
