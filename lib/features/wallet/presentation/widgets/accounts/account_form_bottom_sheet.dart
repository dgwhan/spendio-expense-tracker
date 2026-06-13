import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/constants/app_radius.dart';
import 'package:spend_io_app/core/utils/account_type_ext.dart';
import 'package:spend_io_app/features/wallet/domain/entities/account_entity.dart';

class AccountFormBottomSheet extends StatefulWidget {
  final AccountEntity? account;
  final String title;
  final String actionLabel;
  final Function(String name, AccountType type, double balance) onSubmit;

  const AccountFormBottomSheet({
    super.key,
    this.account,
    required this.title,
    required this.actionLabel,
    required this.onSubmit,
  });

  @override
  State<AccountFormBottomSheet> createState() => _AccountFormBottomSheetState();
}

class _AccountFormBottomSheetState extends State<AccountFormBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _balanceController;
  late AccountType _selectedType;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.account?.name ?? '');
    _balanceController = TextEditingController(
      text: widget.account != null ? widget.account!.balance.toStringAsFixed(0) : '',
    );
    _selectedType = widget.account?.type ?? AccountType.cash;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  IconData _getDefaultIcon(AccountType type) {
    switch (type) {
      case AccountType.cash:
        return Icons.wallet;
      case AccountType.bank:
        return Icons.account_balance;
      case AccountType.eWallet:
        return Icons.account_balance_wallet;
      case AccountType.creditCard:
        return Icons.credit_card;
      case AccountType.savingsAccount:
        return Icons.savings;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final keyboardPadding = MediaQuery.of(context).viewInsets.bottom;

    final backgroundColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final primaryTextColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedTextColor = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
    final inputFillColor = isDark ? AppColors.surfaceSecondaryDark : Colors.grey.shade50;
    final borderColor = isDark ? AppColors.borderDark : Colors.grey.shade300;
    final itemBgColor = isDark ? AppColors.surfaceDark : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppRadius.cardRadiusLg),
          topRight: Radius.circular(AppRadius.cardRadiusLg),
        ),
      ),
      child: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSizes.lg,
            AppSizes.lg,
            AppSizes.lg,
            AppSizes.lg + (keyboardPadding > 0 ? keyboardPadding : MediaQuery.of(context).padding.bottom),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.borderDark : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.lg),
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor,
                ),
              ),
              const SizedBox(height: AppSizes.lg),
              
              // Only inputs are scrollable to keep buttons docked at the bottom
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name input
                      TextFormField(
                        controller: _nameController,
                        style: TextStyle(color: primaryTextColor),
                        decoration: InputDecoration(
                          labelText: 'Account Name',
                          hintText: 'e.g. My Savings, Daily Cash',
                          labelStyle: TextStyle(color: mutedTextColor),
                          hintStyle: TextStyle(color: mutedTextColor.withValues(alpha: 0.7)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            borderSide: const BorderSide(color: AppColors.primary, width: 2),
                          ),
                          filled: true,
                          fillColor: inputFillColor,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Account name is required';
                          }
                          if (value.trim().length < 2) {
                            return 'Account name must be at least 2 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSizes.md),

                      // Balance input
                      TextFormField(
                        controller: _balanceController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: TextStyle(color: primaryTextColor),
                        decoration: InputDecoration(
                          labelText: 'Balance',
                          hintText: '0.00',
                          labelStyle: TextStyle(color: mutedTextColor),
                          hintStyle: TextStyle(color: mutedTextColor.withValues(alpha: 0.7)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            borderSide: const BorderSide(color: AppColors.primary, width: 2),
                          ),
                          filled: true,
                          fillColor: inputFillColor,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Balance is required';
                          }
                          if (double.tryParse(value.trim()) == null) {
                            return 'Please enter a valid numeric value';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSizes.lg),

                      Text(
                        'Account Type',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: primaryTextColor,
                        ),
                      ),
                      const SizedBox(height: AppSizes.sm),

                      // Account Type Selector
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: AppSizes.sm,
                          mainAxisSpacing: AppSizes.sm,
                          childAspectRatio: 2.2,
                        ),
                        itemCount: AccountType.values.length,
                        itemBuilder: (context, index) {
                          final type = AccountType.values[index];
                          final isSelected = _selectedType == type;
                          final Color typeColor = type.mainColor;
                          final Color bgColor = isDark ? typeColor.withValues(alpha: 0.2) : type.bgColor;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedType = type;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                              decoration: BoxDecoration(
                                color: isSelected ? bgColor : itemBgColor,
                                borderRadius: BorderRadius.circular(AppRadius.md),
                                border: Border.all(
                                  color: isSelected ? typeColor : borderColor,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _getDefaultIcon(type),
                                    color: isSelected ? typeColor : mutedTextColor,
                                    size: 24,
                                  ),
                                  const SizedBox(width: AppSizes.sm),
                                  Expanded(
                                    child: Text(
                                      type.displayName,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        color: isSelected
                                            ? primaryTextColor
                                            : (isDark ? AppColors.textSecondaryDark : Colors.grey.shade700),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.md),

              // Sticky Buttons at the bottom
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        side: BorderSide(color: borderColor),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (!_formKey.currentState!.validate()) return;
                        final name = _nameController.text.trim();
                        final balance = double.parse(_balanceController.text.trim());
                        widget.onSubmit(name, _selectedType, balance);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      child: Text(widget.actionLabel),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
