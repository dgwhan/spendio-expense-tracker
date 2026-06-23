import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/constants/app_text_styles.dart';
import 'package:spend_io_app/core/utils/currency_input_formatter.dart';
import 'package:spend_io_app/core/utils/currency_formatter.dart';
import 'package:spend_io_app/core/currency/currency_context.dart';
import 'package:spend_io_app/core/widgets/bottom_sheets/app_bottom_sheet_header.dart';
import 'package:spend_io_app/core/widgets/common/app_dual_action_buttons.dart';
import 'package:spend_io_app/core/widgets/common/app_input_decoration.dart';
import 'package:spend_io_app/core/widgets/button/app_action_button.dart';
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
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final amount = CurrencyFormatter.parse(
      _amountController.text,
      currencyCode: context.currencyContext.preferredCurrencyCode,
    );

    if (amount == null || amount <= 0) return;

    final contribution = SavingGoalContributionEntity(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      goalId: widget.goalId,
      userId: widget.userId,
      amount: amount,
      createdAt: DateTime.now(),
      currencyCode: context.currencyContext.preferredCurrencyCode,
    );

    widget.onSubmit(contribution);
    Navigator.pop(context);
  }

  Widget _buildFieldTitle(String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: RichText(
        text: TextSpan(
          text: title,
          style: AppTextStyles.sectionTitle.copyWith(
            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
          ),
          children: const [
            TextSpan(text: ' *', style: TextStyle(color: AppColors.error)),
          ],
        ),
      ),
    );
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
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppBottomSheetHeader(
                title: 'Amount to Deposit',
                subtitle: 'Enter the amount you want to add to this goal.',
              ),
              const SizedBox(height: AppSizes.xl),
              _buildFieldTitle('Amount'),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CurrencyInputFormatter(
                    currencyCode: context.currencyContext.preferredCurrencyCode,
                  ),
                ],
                decoration: AppInputDecoration.getFieldDecoration(
                  context: context,
                  labelText: '',
                  hintText: '0',
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter an amount';
                  }
                  final amount = CurrencyFormatter.parse(v, currencyCode: context.currencyContext.preferredCurrencyCode);
                  if (amount == null || amount <= 0) {
                    return 'Invalid amount';
                  }
                  if (amount > 999999999) {
                    return 'Amount cannot exceed 999.999.999';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.lg),
              AppDualActionButtons(
                primaryLabel: 'Cancel',
                secondaryLabel: 'Add',
                onPrimaryPressed: () => Navigator.pop(context),
                onSecondaryPressed: _submit,
                primaryVariant: AppActionButtonVariant.cancel,
                secondaryVariant: AppActionButtonVariant.primary,
              ),
              const SizedBox(height: AppSizes.md),
            ],
          ),
        ),
      ),
    );
  }
}
