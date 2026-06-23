import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/constants/app_text_styles.dart';
import 'package:spend_io_app/core/utils/currency_input_formatter.dart';
import 'package:spend_io_app/core/utils/currency_formatter.dart';
import 'package:spend_io_app/core/widgets/app_header.dart';
import 'package:spend_io_app/core/widgets/common/app_dual_action_buttons.dart';
import 'package:spend_io_app/core/widgets/common/app_input_decoration.dart';
import 'package:spend_io_app/core/widgets/button/app_action_button.dart';
import 'package:spend_io_app/features/saving_goal/domain/entities/saving_goal_entity.dart';
import 'package:spend_io_app/features/saving_goal/presentation/viewmodels/saving_goal_detail_viewmodel.dart';

class EditSavingGoalScreen extends StatefulWidget {
  final SavingGoalEntity goal;
  const EditSavingGoalScreen({super.key, required this.goal});

  @override
  State<EditSavingGoalScreen> createState() => _EditSavingGoalScreenState();
}

class _EditSavingGoalScreenState extends State<EditSavingGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _targetController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.goal.title);
    final formatter = NumberFormat.decimalPattern('vi_VN');
    final targetStr = formatter.format(widget.goal.targetAmount.round());
    _targetController = TextEditingController(text: targetStr);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final vm = context.read<SavingGoalDetailViewModel>();

    final targetAmount = CurrencyFormatter.parse(
      _targetController.text,
      currencyCode: widget.goal.currencyCode,
    ) ?? widget.goal.targetAmount;

    final progress = targetAmount <= 0
        ? 0.0
        : (widget.goal.cachedCurrentAmount / targetAmount)
            .clamp(0.0, 1.0)
            .toDouble();

    final updated = widget.goal.copyWith(
      title: _titleController.text.trim(),
      targetAmount: targetAmount,
      cachedProgress: progress,
      updatedAt: DateTime.now(),
    );

    await vm.updateGoal(goal: updated);
    if (mounted) Navigator.pop(context, true);
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
    final vm = context.watch<SavingGoalDetailViewModel>();

    return Scaffold(
      appBar: const AppHeader(title: 'Edit Goal', showBack: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildFieldTitle('Title'),
                TextFormField(
                  controller: _titleController,
                  decoration: AppInputDecoration.getFieldDecoration(
                    context: context,
                    labelText: '',
                    hintText: 'Enter goal title',
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: AppSizes.md),
                _buildFieldTitle('Target Amount'),
                TextFormField(
                  controller: _targetController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    CurrencyInputFormatter(currencyCode: widget.goal.currencyCode),
                  ],
                  decoration: AppInputDecoration.getFieldDecoration(
                    context: context,
                    labelText: '',
                    hintText: '0',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Invalid amount';
                    final amount = CurrencyFormatter.parse(v, currencyCode: widget.goal.currencyCode);
                    if (amount == null || amount <= 0) return 'Invalid amount';
                    if (amount > 999999999) {
                      return 'Amount cannot exceed 999.999.999';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSizes.xl),
                AppDualActionButtons(
                  primaryLabel: 'Cancel',
                  secondaryLabel: vm.loading ? 'Saving...' : 'Save Changes',
                  onPrimaryPressed: () => Navigator.pop(context, false),
                  onSecondaryPressed: vm.loading ? null : _save,
                  primaryVariant: AppActionButtonVariant.cancel,
                  secondaryVariant: AppActionButtonVariant.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
