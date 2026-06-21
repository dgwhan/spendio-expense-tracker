import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/widgets/primary_button.dart';
import 'package:spend_io_app/core/widgets/app_header.dart';
import 'package:spend_io_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:spend_io_app/features/saving_goal/domain/entities/saving_goal_entity.dart';
import 'package:spend_io_app/features/saving_goal/presentation/viewmodels/create_saving_goal_viewmodel.dart';
import 'package:spend_io_app/features/saving_goal/presentation/widgets/bottom/color_picker_bottom_sheet.dart';
import 'package:spend_io_app/features/saving_goal/presentation/widgets/bottom/icon_picker_bottom_sheet.dart';
import 'package:spend_io_app/features/saving_goal/presentation/widgets/form/goal_name_field.dart';
import 'package:spend_io_app/features/saving_goal/presentation/widgets/form/goal_target_amount_field.dart';
import 'package:spend_io_app/features/saving_goal/presentation/widgets/form/goal_initial_amount_field.dart';
import 'package:spend_io_app/features/saving_goal/presentation/widgets/preview/goal_preview_card.dart';
import 'package:spend_io_app/features/saving_goal/presentation/widgets/section/goal_color_picker_section.dart';
import 'package:spend_io_app/features/saving_goal/presentation/widgets/section/goal_icon_picker_section.dart';

class CreateSavingGoalScreen extends StatefulWidget {
  const CreateSavingGoalScreen({super.key});

  @override
  State<CreateSavingGoalScreen> createState() => _CreateSavingGoalScreenState();
}

class _CreateSavingGoalScreenState extends State<CreateSavingGoalScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _targetController;
  late final TextEditingController _initialController;

  int _selectedColorValue = AppColors.primary.toARGB32();
  int _selectedIconCode = Icons.flag_rounded.codePoint;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController();
    _targetController = TextEditingController();
    _initialController = TextEditingController(text: '0');

    _nameController.addListener(_refreshPreview);
    _targetController.addListener(_refreshPreview);
    _initialController.addListener(_refreshPreview);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _initialController.dispose();
    super.dispose();
  }

  void _refreshPreview() {
    setState(() {});
  }

  Future<void> _saveGoal() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;

    if (user == null || user.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User not found'),
        ),
      );
      return;
    }

    final now = DateTime.now();
    final targetAmount = double.tryParse(_targetController.text) ?? 0;
    final initialAmount = double.tryParse(_initialController.text) ?? 0;

    final progress = targetAmount <= 0
        ? 0.0
        : (initialAmount / targetAmount).clamp(0.0, 1.0).toDouble();

    final goal = SavingGoalEntity(
      id: now.microsecondsSinceEpoch.toString(),
      userId: user.id!,
      title: _nameController.text.trim(),
      targetAmount: targetAmount,
      initialAmount: initialAmount,
      cachedCurrentAmount: initialAmount,
      cachedProgress: progress,
      iconCodePoint: _selectedIconCode,
      iconFontFamily: 'MaterialIcons',
      colorValue: _selectedColorValue,
      status: 'active',
      createdAt: now,
      updatedAt: now,
    );

    try {
      await context.read<CreateSavingGoalViewModel>().createGoal(goal: goal);

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CreateSavingGoalViewModel>();
    final targetAmount = double.tryParse(_targetController.text) ?? 0;
    final initialAmount = double.tryParse(_initialController.text) ?? 0;

    return Scaffold(
      appBar: AppHeader(
        title: 'Create Saving Goal',
        showBack: true,
        onBack: () => Navigator.pop(context),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.md),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: constraints.maxWidth,
                  maxWidth: constraints.maxWidth,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GoalPreviewCard(
                        title: _nameController.text,
                        targetAmount: targetAmount,
                        initialAmount: initialAmount,
                        colorValue: _selectedColorValue,
                        iconCodePoint: _selectedIconCode,
                      ),
                      const SizedBox(height: AppSizes.lg),
                      GoalNameField(
                        controller: _nameController,
                      ),
                      const SizedBox(height: AppSizes.md),
                      GoalTargetAmountField(
                        controller: _targetController,
                      ),
                      const SizedBox(height: AppSizes.md),
                      GoalInitialAmountField(
                        controller: _initialController,
                      ),
                      const SizedBox(height: AppSizes.lg),
                      GoalIconPickerSection(
                        selectedIcon: _selectedIconCode,
                        activeColor: _selectedColorValue,
                        onChanged: (value) {
                          setState(() => _selectedIconCode = value);
                        },
                        onViewAll: () async {
                          final result = await IconPickerBottomSheet.show(
                            context: context,
                            selectedIcon: _selectedIconCode,
                            activeColor: _selectedColorValue,
                          );

                          if (result != null) {
                            setState(() => _selectedIconCode = result);
                          }
                        },
                      ),
                      const SizedBox(height: AppSizes.lg),
                      GoalColorPickerSection(
                        selectedColor: _selectedColorValue,
                        onChanged: (value) {
                          setState(() => _selectedColorValue = value);
                        },
                        onViewAll: () async {
                          final result = await ColorPickerBottomSheet.show(
                            context: context,
                            selectedColor: _selectedColorValue,
                          );

                          if (result != null) {
                            setState(() => _selectedColorValue = result);
                          }
                        },
                      ),
                      const SizedBox(height: 32),
                      PrimaryButton(
                        title: vm.loading ? 'Saving...' : 'Create Goal',
                        onPressed: vm.loading ? null : _saveGoal,
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
