import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/constants/app_radius.dart';
import 'package:spend_io_app/core/constants/app_text_styles.dart';
import 'package:spend_io_app/core/widgets/common/app_dual_action_buttons.dart';
import 'package:spend_io_app/features/account/domain/entities/account_entity.dart';
import 'package:spend_io_app/features/account/presentation/widgets/account_type_grid_selector.dart';

class AccountForm extends StatefulWidget {
  final AccountEntity? account;
  final String title;
  final String actionLabel;
  final Function(String name, AccountType type, double balance) onSubmit;

  const AccountForm({
    super.key,
    this.account,
    required this.title,
    required this.actionLabel,
    required this.onSubmit,
  });

  @override
  State<AccountForm> createState() => _AccountFormState();
}

class _AccountFormState extends State<AccountForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _balanceController;
  late AccountType _selectedType;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.account?.name ?? '');

    // Thêm định dạng phân tách hàng nghìn cho balance ban đầu nếu có sẵn dữ liệu edit
    if (widget.account != null) {
      final String initialFormatted = NumberFormat('#,###', 'vi_VN')
          .format(widget.account!.balance.toInt());
      _balanceController = TextEditingController(text: initialFormatted);
    } else {
      _balanceController = TextEditingController(text: '');
    }
    _selectedType = widget.account?.type ?? AccountType.cash;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedTextColor =
        isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
    final inputFillColor = isDark
        ? AppColors.surfaceSecondaryDark
        : AppColors.surfaceSecondaryLight;

    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: AppTextStyles.headingMedium
                  .copyWith(color: primaryTextColor, fontSize: 20),
            ),
            const SizedBox(height: AppSizes.lg),

            // Name Field
            TextFormField(
              controller: _nameController,
              style: AppTextStyles.bodyNormal.copyWith(color: primaryTextColor),
              decoration: InputDecoration(
                labelText: 'Account Name',
                hintText: 'e.g. My Savings, Daily Cash',
                labelStyle:
                    AppTextStyles.caption.copyWith(color: mutedTextColor),
                hintStyle: AppTextStyles.bodyNormal
                    .copyWith(color: mutedTextColor.withValues(alpha: 0.6)),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 1.5),
                ),
                filled: true,
                fillColor: inputFillColor,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty)
                  return 'Account name is required';
                if (value.trim().length < 2)
                  return 'Account name must be at least 2 characters';
                return null;
              },
            ),
            const SizedBox(height: AppSizes.md),

            // Balance Field với bộ gõ phân tách hàng nghìn động
            TextFormField(
              controller: _balanceController,
              keyboardType: TextInputType.number,
              style: AppTextStyles.bodyNormal.copyWith(color: primaryTextColor),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                TextInputFormatter.withFunction((oldValue, newValue) {
                  if (newValue.text.isEmpty) return newValue;
                  final int value =
                      int.parse(newValue.text.replaceAll('.', ''));
                  final String formatted =
                      NumberFormat('#,###', 'vi_VN').format(value);
                  return newValue.copyWith(
                    text: formatted,
                    selection:
                        TextSelection.collapsed(offset: formatted.length),
                  );
                }),
              ],
              decoration: InputDecoration(
                labelText: 'Balance',
                hintText: '0',
                labelStyle:
                    AppTextStyles.caption.copyWith(color: mutedTextColor),
                hintStyle: AppTextStyles.bodyNormal
                    .copyWith(color: mutedTextColor.withValues(alpha: 0.6)),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 1.5),
                ),
                filled: true,
                fillColor: inputFillColor,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty)
                  return 'Balance is required';
                return null;
              },
            ),
            const SizedBox(height: AppSizes.lg),

            Text(
              'Account Type',
              style:
                  AppTextStyles.sectionTitle.copyWith(color: primaryTextColor),
            ),
            const SizedBox(height: AppSizes.sm),

            AccountTypeGridSelector(
              selectedType: _selectedType,
              onTypeSelected: (type) => setState(() => _selectedType = type),
            ),
            const SizedBox(height: AppSizes.xl),

            // Dual Action Buttons xử lý mượt bàn phím ảo và microtask điều hướng
            AppDualActionButtons(
              primaryLabel: widget.actionLabel,
              secondaryLabel: 'Cancel',
              onPrimaryPressed: () {
                if (!_formKey.currentState!.validate()) return;
                final name = _nameController.text.trim();
                final rawBalance =
                    _balanceController.text.replaceAll('.', '').trim();
                final balance = double.tryParse(rawBalance) ?? 0.0;
                widget.onSubmit(name, _selectedType, balance);
              },
              onSecondaryPressed: () {
                FocusScope.of(context)
                    .unfocus(); // Giải phóng tiêu điểm bàn phím ảo tránh lỗi layout
                Future.microtask(() {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
