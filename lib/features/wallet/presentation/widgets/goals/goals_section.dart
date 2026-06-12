import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/constants/app_radius.dart';
import 'package:spend_io_app/features/wallet/domain/entities/saving_goal_entity.dart';
import 'package:spend_io_app/features/wallet/presentation/viewmodels/wallet_viewmodel.dart';
import 'package:spend_io_app/shared/headers/app_section_header.dart';
import 'package:spend_io_app/shared/states/section_empty_state.dart';
import 'saving_goal_card.dart';

class GoalsSection extends StatelessWidget {
  const GoalsSection({super.key});

  void _showAddGoalDialog(BuildContext context, WalletViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final formKey = GlobalKey<FormState>();
        final nameController = TextEditingController();
        final targetAmountController = TextEditingController();
        final currentAmountController = TextEditingController();
        final dateController = TextEditingController();
        
        DateTime? selectedDate;
        IconData selectedIcon = Icons.savings;

        final List<Map<String, dynamic>> availableIcons = [
          {'icon': Icons.savings, 'label': 'Savings'},
          {'icon': Icons.laptop_mac, 'label': 'Tech'},
          {'icon': Icons.flight, 'label': 'Travel'},
          {'icon': Icons.directions_car, 'label': 'Vehicle'},
          {'icon': Icons.home, 'label': 'Home'},
          {'icon': Icons.school, 'label': 'Education'},
        ];

        Future<void> selectDate(BuildContext context, StateSetter setState) async {
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now().add(const Duration(days: 30)),
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: AppColors.primary,
                    onPrimary: Colors.white,
                    onSurface: AppColors.textPrimaryLight,
                  ),
                ),
                child: child!,
              );
            },
          );

          if (picked != null) {
            setState(() {
              selectedDate = picked;
              dateController.text = DateFormat('yyyy-MM-dd').format(picked);
            });
          }
        }

        return StatefulBuilder(
          builder: (context, setState) {
            final keyboardPadding = MediaQuery.of(context).viewInsets.bottom;
            return Container(
              padding: EdgeInsets.fromLTRB(
                AppSizes.lg,
                AppSizes.lg,
                AppSizes.lg,
                AppSizes.lg + keyboardPadding,
              ),
              decoration: const BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.cardRadiusLg),
                  topRight: Radius.circular(AppRadius.cardRadiusLg),
                ),
              ),
              child: Form(
                key: formKey,
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
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSizes.lg),
                      const Text(
                        'Create Saving Goal',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: AppSizes.md),
                      const Text(
                        'Set a target and track your savings progression.',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textMutedLight,
                        ),
                      ),
                      const SizedBox(height: AppSizes.lg),

                      // Name input
                      TextFormField(
                        controller: nameController,
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          labelText: 'Goal Name',
                          hintText: 'e.g. Vacation, Emergency Fund',
                          labelStyle: const TextStyle(color: AppColors.textMutedLight),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            borderSide: const BorderSide(color: AppColors.primary, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
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
                        controller: targetAmountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          labelText: 'Target Amount',
                          hintText: '0.00',
                          labelStyle: const TextStyle(color: AppColors.textMutedLight),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            borderSide: const BorderSide(color: AppColors.primary, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter target amount';
                          }
                          if (double.tryParse(value.trim()) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSizes.md),

                      // Current Amount input
                      TextFormField(
                        controller: currentAmountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          labelText: 'Current Saved Amount',
                          hintText: '0.00 (optional)',
                          labelStyle: const TextStyle(color: AppColors.textMutedLight),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            borderSide: const BorderSide(color: AppColors.primary, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        validator: (value) {
                          if (value != null && value.trim().isNotEmpty) {
                            if (double.tryParse(value.trim()) == null) {
                              return 'Please enter a valid number';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSizes.md),

                      // Estimated Date picker
                      TextFormField(
                        controller: dateController,
                        readOnly: true,
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          labelText: 'Target Date',
                          hintText: 'Select Estimated Date',
                          labelStyle: const TextStyle(color: AppColors.textMutedLight),
                          suffixIcon: const Icon(Icons.calendar_today, color: AppColors.primary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            borderSide: const BorderSide(color: AppColors.primary, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        onTap: () => selectDate(context, setState),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select target date';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSizes.lg),

                      const Text(
                        'Select Goal Icon',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: AppSizes.sm),

                      // Icon Chips
                      SizedBox(
                        height: 48,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: availableIcons.length,
                          itemBuilder: (context, index) {
                            final item = availableIcons[index];
                            final icon = item['icon'] as IconData;
                            final label = item['label'] as String;
                            final isSelected = selectedIcon == icon;

                            return Padding(
                              padding: const EdgeInsets.only(right: AppSizes.sm),
                              child: ChoiceChip(
                                label: Text(label),
                                selected: isSelected,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
                                      selectedIcon = icon;
                                    });
                                  }
                                },
                                selectedColor: AppColors.primary.withValues(alpha: 0.2),
                                checkmarkColor: AppColors.primary,
                                labelStyle: TextStyle(
                                  color: isSelected ? AppColors.primary : Colors.grey.shade700,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                                avatar: Icon(
                                  icon,
                                  color: isSelected ? AppColors.primary : Colors.grey,
                                  size: 18,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: AppSizes.xl),

                      // Action buttons
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
                              ),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: AppSizes.md),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                if (!formKey.currentState!.validate()) return;
                                final name = nameController.text.trim();
                                final targetAmount = double.tryParse(targetAmountController.text.trim()) ?? 0.0;
                                final currentAmount = double.tryParse(currentAmountController.text.trim()) ?? 0.0;
                                final estimatedDate = selectedDate ?? DateTime.now().add(const Duration(days: 90));

                                final newGoal = SavingGoalEntity(
                                  id: 'goal_${DateTime.now().millisecondsSinceEpoch}',
                                  name: name,
                                  currentAmount: currentAmount,
                                  targetAmount: targetAmount,
                                  estimatedDate: estimatedDate,
                                  icon: selectedIcon,
                                );

                                viewModel.addNewGoal(newGoal);
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
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<WalletViewModel>();
    final liveGoals = viewModel.goals;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(
          title: 'Savings Goals',
          fontSize: 26,
          actionLabel: 'Add',
          onActionTap: () {
            _showAddGoalDialog(context, viewModel);
          },
        ),
        const SizedBox(height: AppSizes.md),

        // XỬ LÝ ĐIỀU KIỆN EMPTY STATE (PR-09)
        liveGoals.isEmpty
            ? SectionEmptyState(
                title: 'No Saving Goals',
                subtitle: 'Create a goal and start\nbuilding your future.',
                icon: Icons.track_changes_outlined,
                actionLabel: 'Create Goal',
                onActionTap: () {
                  _showAddGoalDialog(context, viewModel);
                },
              )
            : Column(
                children: liveGoals
                    .map((goal) => SavingGoalCard(goal: goal))
                    .toList(),
              ),
      ],
    );
  }
}
