import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/widgets/primary_button.dart';
import 'package:spend_io_app/core/widgets/app_header.dart';
import 'package:spend_io_app/core/widgets/common/app_dual_action_buttons.dart'; // Đã import component
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
import 'package:spend_io_app/core/utils/currency_formatter.dart';
import 'package:spend_io_app/core/currency/currency_context.dart';

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
    _nameController = TextEditingController()..addListener(_refreshPreview);
    _targetController = TextEditingController()..addListener(_refreshPreview);
    _initialController = TextEditingController(text: '0')
      ..addListener(_refreshPreview);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _initialController.dispose();
    super.dispose();
  }

  void _refreshPreview() => setState(() {});

  Future<void> _saveGoal() async {
    if (!_formKey.currentState!.validate()) return;
    final user = context.read<AuthProvider>().currentUser;
    if (user == null || user.id == null) return;

    final preferredCurrency = context.currencyContext.preferredCurrencyCode;
    final targetAmount = CurrencyFormatter.parse(_targetController.text, currencyCode: preferredCurrency) ?? 0;
    final initialAmount = CurrencyFormatter.parse(_initialController.text, currencyCode: preferredCurrency) ?? 0;
    final progress = targetAmount <= 0
        ? 0.0
        : (initialAmount / targetAmount).clamp(0.0, 1.0).toDouble();

    final goal = SavingGoalEntity(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
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
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      currencyCode: context.currencyContext.preferredCurrencyCode,
    );

    await context.read<CreateSavingGoalViewModel>().createGoal(goal: goal);
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CreateSavingGoalViewModel>();
    final preferredCurrency = context.currencyContext.preferredCurrencyCode;
    final targetAmount = CurrencyFormatter.parse(_targetController.text, currencyCode: preferredCurrency) ?? 0;
    final initialAmount = CurrencyFormatter.parse(_initialController.text, currencyCode: preferredCurrency) ?? 0;

    return Scaffold(
      appBar: const AppHeader(title: 'Create Saving Goal', showBack: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.md),
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
                  currencyCode: context.currencyContext.preferredCurrencyCode,
                ),
                const SizedBox(height: AppSizes.lg),
                GoalNameField(controller: _nameController),
                const SizedBox(height: AppSizes.md),
                GoalTargetAmountField(
                  controller: _targetController,
                  currencyCode: context.currencyContext.preferredCurrencyCode,
                ),
                const SizedBox(height: AppSizes.md),
                GoalInitialAmountField(
                  controller: _initialController,
                  currencyCode: context.currencyContext.preferredCurrencyCode,
                ),
                const SizedBox(height: AppSizes.lg),
                GoalIconPickerSection(
                  selectedIcon: _selectedIconCode,
                  activeColor: _selectedColorValue,
                  onChanged: (v) => setState(() => _selectedIconCode = v),
                  onViewAll: () async {
                    final res = await IconPickerBottomSheet.show(
                        context: context,
                        selectedIcon: _selectedIconCode,
                        activeColor: _selectedColorValue);
                    if (res != null) setState(() => _selectedIconCode = res);
                  },
                ),
                const SizedBox(height: AppSizes.md),
                GoalColorPickerSection(
                  selectedColor: _selectedColorValue,
                  onChanged: (v) => setState(() => _selectedColorValue = v),
                  onViewAll: () async {
                    final res = await ColorPickerBottomSheet.show(
                        context: context, selectedColor: _selectedColorValue);
                    if (res != null) setState(() => _selectedColorValue = res);
                  },
                ),
                const SizedBox(height: 32),
                AppDualActionButtons(
                  primaryLabel: 'Cancel',
                  secondaryLabel: vm.loading ? 'Saving...' : 'Create Goal',
                  onPrimaryPressed: () => Navigator.pop(context),
                  onSecondaryPressed: vm.loading ? null : _saveGoal,
                  primaryVariant: AppButtonVariant.cancel,
                  secondaryVariant: AppButtonVariant.primary,
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
