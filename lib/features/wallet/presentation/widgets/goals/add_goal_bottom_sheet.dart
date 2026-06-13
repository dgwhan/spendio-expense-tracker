import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/constants/app_radius.dart';
import 'package:spend_io_app/features/wallet/domain/entities/saving_goal_entity.dart';
import 'package:spend_io_app/features/wallet/presentation/viewmodels/wallet_viewmodel.dart';

class AddGoalBottomSheet extends StatefulWidget {
  final WalletViewModel viewModel;

  const AddGoalBottomSheet({super.key, required this.viewModel});

  @override
  State<AddGoalBottomSheet> createState() => _AddGoalBottomSheetState();
}

class _AddGoalBottomSheetState extends State<AddGoalBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _currentAmountController = TextEditingController();
  DateTime _estimatedDate = DateTime.now().add(const Duration(days: 90));
  IconData _selectedIcon = Icons.savings;

  final List<IconData> _icons = [
    Icons.savings,
    Icons.directions_car,
    Icons.home,
    Icons.flight,
    Icons.school,
    Icons.laptop,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _targetAmountController.dispose();
    _currentAmountController.dispose();
    super.dispose();
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
    final containerColor = isDark ? AppColors.surfaceDark : Colors.white;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSizes.lg,
        AppSizes.lg,
        AppSizes.lg,
        AppSizes.lg + keyboardPadding,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppRadius.cardRadiusLg),
          topRight: Radius.circular(AppRadius.cardRadiusLg),
        ),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
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
                'Create Saving Goal',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor,
                ),
              ),
              const SizedBox(height: AppSizes.md),
              Text(
                'Define a financial goal you want to save for.',
                style: TextStyle(
                  fontSize: 14,
                  color: mutedTextColor,
                ),
              ),
              const SizedBox(height: AppSizes.lg),

              // Name input
              TextFormField(
                controller: _nameController,
                style: TextStyle(color: primaryTextColor),
                decoration: InputDecoration(
                  labelText: 'Goal Name',
                  hintText: 'e.g. Vacation, New Laptop, Car Deposit',
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
                    return 'Please enter goal name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.md),

              // Target Amount input
              TextFormField(
                controller: _targetAmountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(color: primaryTextColor),
                decoration: InputDecoration(
                  labelText: 'Target Amount',
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
                    return 'Please enter target amount';
                  }
                  final parsed = double.tryParse(value.trim());
                  if (parsed == null || parsed <= 0) {
                    return 'Please enter a valid amount greater than 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.md),

              // Current Saved input
              TextFormField(
                controller: _currentAmountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(color: primaryTextColor),
                decoration: InputDecoration(
                  labelText: 'Already Saved (Optional)',
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
                  if (value != null && value.trim().isNotEmpty) {
                    final parsed = double.tryParse(value.trim());
                    if (parsed == null || parsed < 0) {
                      return 'Please enter a valid non-negative amount';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.md),

              // Estimated Date picker field
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _estimatedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 20)),
                    builder: (context, child) {
                      return Theme(
                        data: isDark
                            ? ThemeData.dark().copyWith(
                                colorScheme: const ColorScheme.dark(
                                  primary: AppColors.primary,
                                  onPrimary: Colors.white,
                                  surface: AppColors.surfaceDark,
                                  onSurface: Colors.white,
                                ),
                              )
                            : ThemeData.light().copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: AppColors.primary,
                                  onPrimary: Colors.white,
                                  surface: Colors.white,
                                  onSurface: Colors.black,
                                ),
                              ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    setState(() {
                      _estimatedDate = picked;
                    });
                  }
                },
                child: IgnorePointer(
                  child: TextFormField(
                    style: TextStyle(color: primaryTextColor),
                    decoration: InputDecoration(
                      labelText: 'Target Date',
                      labelStyle: TextStyle(color: mutedTextColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      filled: true,
                      fillColor: inputFillColor,
                      suffixIcon: Icon(Icons.calendar_today, color: mutedTextColor),
                    ),
                    controller: TextEditingController(
                      text: "${_estimatedDate.day}/${_estimatedDate.month}/${_estimatedDate.year}",
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.lg),

              Text(
                'Goal Icon',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor,
                ),
              ),
              const SizedBox(height: AppSizes.sm),

              // Goal Icon Selector Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _icons.map((icon) {
                  final isSelected = _selectedIcon == icon;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIcon = icon;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(AppSizes.sm),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary.withValues(alpha: 0.15) : containerColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? AppColors.primary : borderColor,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: isSelected ? AppColors.primary : mutedTextColor,
                        size: 28,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSizes.xl),

              // Action Buttons
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
                        style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (!_formKey.currentState!.validate()) return;
                        final name = _nameController.text.trim();
                        final targetAmount = double.tryParse(_targetAmountController.text.trim()) ?? 0.0;
                        final currentAmount = double.tryParse(_currentAmountController.text.trim()) ?? 0.0;

                        final newGoal = SavingGoalEntity(
                          id: 'goal_${DateTime.now().millisecondsSinceEpoch}',
                          name: name,
                          targetAmount: targetAmount,
                          currentAmount: currentAmount,
                          estimatedDate: _estimatedDate,
                          icon: _selectedIcon,
                        );

                        widget.viewModel.addNewGoal(newGoal);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      child: const Text('Create'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.md),
            ],
          ),
        ),
      ),
    );
  }
}
