import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/widgets/app_header.dart';
import 'package:spend_io_app/features/saving_goal/domain/entities/saving_goal_entity.dart';
import 'package:spend_io_app/features/saving_goal/presentation/viewmodels/saving_goal_detail_viewmodel.dart';

class EditSavingGoalScreen extends StatefulWidget {
  final SavingGoalEntity goal;

  const EditSavingGoalScreen({
    super.key,
    required this.goal,
  });

  @override
  State<EditSavingGoalScreen> createState() => _EditSavingGoalScreenState();
}

class _EditSavingGoalScreenState extends State<EditSavingGoalScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _targetController;

  late int _color;
  late int _icon;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.goal.title);
    _targetController = TextEditingController(
        text: widget.goal.targetAmount.toStringAsFixed(0));

    _color = widget.goal.colorValue;
    _icon = widget.goal.iconCodePoint;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final vm = context.read<SavingGoalDetailViewModel>();

    final targetAmount =
        double.tryParse(_targetController.text) ?? widget.goal.targetAmount;

    // Tự động tính toán lại tiến trình % dựa trên số tiền mục tiêu mới thay đổi
    final progress = targetAmount <= 0
        ? 0.0
        : (widget.goal.cachedCurrentAmount / targetAmount)
            .clamp(0.0, 1.0)
            .toDouble();

    final updated = SavingGoalEntity(
      id: widget.goal.id,
      userId: widget.goal.userId,
      title: _titleController.text.trim(),
      targetAmount: targetAmount,
      initialAmount: widget.goal.initialAmount,
      cachedCurrentAmount: widget.goal.cachedCurrentAmount,
      cachedProgress: progress,
      iconCodePoint: _icon,
      iconFontFamily: widget.goal.iconFontFamily,
      colorValue: _color,
      status: widget.goal.status,
      createdAt: widget.goal.createdAt,
      updatedAt: DateTime.now(),
    );

    await vm.updateGoal(goal: updated);

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // FIX: Thay thế bằng Custom AppHeader
      appBar: AppHeader(
        title: 'Edit Goal',
        showBack: true,
        onBack: () => Navigator.pop(context, false),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter goal title',
                ),
              ),
              const SizedBox(height: AppSizes.md),
              TextField(
                controller: _targetController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Target Amount',
                  hintText: 'Enter target amount',
                ),
              ),
              const SizedBox(height: AppSizes.xl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  child: const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
