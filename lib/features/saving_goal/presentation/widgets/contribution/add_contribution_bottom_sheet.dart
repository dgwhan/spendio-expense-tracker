import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/widgets/bottom_sheets/app_bottom_sheet_header.dart';
import 'package:spend_io_app/features/saving_goal/domain/entities/saving_goal_contribution_entity.dart';

class AddContributionBottomSheet extends StatefulWidget {
  final String goalId;
  final int userId;
  final Function(SavingGoalContributionEntity) onSubmit;

  const AddContributionBottomSheet({
    super.key,
    required this.goalId,
    required this.userId,
    required this.onSubmit,
  });

  @override
  State<AddContributionBottomSheet> createState() =>
      _AddContributionBottomSheetState();
}

class _AddContributionBottomSheetState
    extends State<AddContributionBottomSheet> {
  final TextEditingController _amountController = TextEditingController();

  void _submit() {
    final amount = double.tryParse(_amountController.text.trim());

    if (amount == null || amount <= 0) return;

    final contribution = SavingGoalContributionEntity(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      goalId: widget.goalId,
      userId: widget.userId,
      amount: amount,
      createdAt: DateTime.now(),
    );

    debugPrint('Submit contribution: $amount');

    widget.onSubmit(contribution);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSizes.md,
          right: AppSizes.md,
          top: AppSizes.md,
          bottom: MediaQuery.of(context).viewInsets.bottom + AppSizes.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppBottomSheetHeader(
              title: 'Amount to Deposit',
              subtitle: 'Enter the amount you want to add to this goal.',
            ),
            const SizedBox(height: AppSizes.xl),
            TextField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixText: '\$ ',
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.lg),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Add',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),  
            const SizedBox(height: AppSizes.md),
          ],
        ),
      ),
    );
  }
}
