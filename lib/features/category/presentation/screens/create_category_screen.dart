import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/utils/app_default_categories.dart';
import 'package:spend_io_app/features/category/domain/entities/category_entity.dart';
import 'package:spend_io_app/features/category/presentation/viewmodels/category_viewmodel.dart';
import 'package:spend_io_app/shared/widgets/color_picker/app_color_picker_grid.dart';
import 'package:spend_io_app/shared/widgets/icon_picker/app_icon_picker_grid.dart';

class CreateCategoryScreen extends StatefulWidget {
  final int userId;
  final String remoteUid;

  const CreateCategoryScreen({
    super.key,
    required this.userId,
    required this.remoteUid,
  });

  @override
  State<CreateCategoryScreen> createState() => _CreateCategoryScreenState();
}

class _CreateCategoryScreenState extends State<CreateCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  String _selectedType = 'expense';
  String? _selectedGroup;

  int _selectedIconCode = Icons.local_atm_rounded.codePoint;
  late int _selectedColorValue;

  @override
  void initState() {
    super.initState();
    _selectedColorValue = AppColors.primary.toARGB32();
    _selectedGroup = AppDefaultCategories.expenseGroups.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submitCategory() async {
    if (!_formKey.currentState!.validate() || _selectedGroup == null) return;

    final String uniqueId =
        'custom_cat_${DateTime.now().microsecondsSinceEpoch}';
    final nowString = DateTime.now().toIso8601String();

    final newCategory = CategoryEntity(
      id: uniqueId,
      userId: widget.userId,
      name: _nameController.text.trim(),
      type: _selectedType,
      groupName: _selectedGroup!,
      iconCodePoint: _selectedIconCode, 
      iconFontFamily: 'MaterialIcons',
      colorValue: _selectedColorValue,
      createdAt: nowString,
      updatedAt: nowString,
    );

    final categoryVM = context.read<CategoryViewModel>();

    final errorMessage = await categoryVM.createCustomCategory(
      category: newCategory,
      remoteUid: widget.remoteUid,
      userId: widget.userId,
    );

    if (!mounted) return;

    if (errorMessage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category created successfully!')),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating category: $errorMessage'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final groupList = _selectedType == 'expense'
        ? AppDefaultCategories.expenseGroups
        : AppDefaultCategories.incomeGroups;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Create Custom Category',
          style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(AppSizes.md),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Segmented Flow Selector Tabs
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('Expense')),
                        selected: _selectedType == 'expense',
                        selectedColor: AppColors.error.withValues(alpha: 0.2),
                        labelStyle: TextStyle(
                          color: _selectedType == 'expense'
                              ? AppColors.error
                              : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (_) => setState(() {
                          _selectedType = 'expense';
                          _selectedGroup =
                              AppDefaultCategories.expenseGroups.first;
                        }),
                      ),
                    ),
                    const SizedBox(width: AppSizes.sm),
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('Income')),
                        selected: _selectedType == 'income',
                        selectedColor: AppColors.success.withValues(alpha: 0.2),
                        labelStyle: TextStyle(
                          color: _selectedType == 'income'
                              ? AppColors.success
                              : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (_) => setState(() {
                          _selectedType = 'income';
                          _selectedGroup =
                              AppDefaultCategories.incomeGroups.first;
                        }),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.md),

                // Name Input field 
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Category Name',
                    prefixIcon: Icon(
                      IconData(_selectedIconCode, fontFamily: 'MaterialIcons'),
                      color: Color(_selectedColorValue),
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.md)),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty
                      ? 'Please enter a name'
                      : null,
                ),
                const SizedBox(height: AppSizes.md),

                // Dropdown Chọn Nhóm Danh Mục
                DropdownButtonFormField<String>(
                  key: ValueKey(_selectedType),
                  initialValue: _selectedGroup,
                  decoration: InputDecoration(
                    labelText: 'Assign Group Section',
                    prefixIcon: const Icon(Icons.layers_outlined),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.md)),
                  ),
                  items: groupList
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedGroup = val),
                ),
                const SizedBox(height: AppSizes.lg),

                const Text(
                  'Select Category Icon',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
                ),
                const SizedBox(height: AppSizes.sm),
                AppIconPickerGrid(
                  selectedIconCode: _selectedIconCode,
                  activeColorValue: _selectedColorValue,
                  onIconSelected: (codePoint) {
                    setState(() {
                      _selectedIconCode = codePoint; 
                    });
                  },
                ),
                const SizedBox(height: AppSizes.lg),

                // 5. Bộ chọn Màu Sắc Accent
                const Text(
                  'Select Theme Accent Color',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
                ),
                const SizedBox(height: AppSizes.sm),
                AppColorPickerGrid(
                  selectedColorValue: _selectedColorValue,
                  onColorSelected: (color) {
                    setState(() {
                      _selectedColorValue = color;
                    });
                  },
                ),
                const SizedBox(height: AppSizes.xl),

                // Nút Lưu danh mục
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitCategory,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding:
                          const EdgeInsets.symmetric(vertical: AppSizes.md),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.md)),
                    ),
                    child: const Text('Save Custom Category',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
