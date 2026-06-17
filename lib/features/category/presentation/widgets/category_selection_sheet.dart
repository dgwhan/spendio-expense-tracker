import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:spend_io_app/features/category/domain/entities/category_entity.dart';
import 'package:spend_io_app/features/category/presentation/screens/create_category_screen.dart';
import 'package:spend_io_app/features/category/presentation/viewmodels/category_viewmodel.dart';

class CategorySelectionSheet extends StatefulWidget {
  final String currentType;
  final CategoryEntity? selectedCategory;
  final ValueChanged<CategoryEntity> onCategorySelected;

  const CategorySelectionSheet({
    super.key,
    required this.currentType,
    this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  State<CategorySelectionSheet> createState() => _CategorySelectionSheetState();
}

class _CategorySelectionSheetState extends State<CategorySelectionSheet> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CategoryViewModel>();
    final filteredData = _getFilteredGroupedData(viewModel);

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const _BottomSheetHandle(),
          _buildHeader(context),
          const SizedBox(height: 8),
          const Divider(color: AppColors.dividerLight, height: 1),
          _buildSearchBar(),

          // Khối hiển thị danh sách chính
          Expanded(
            child: viewModel.state.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary))
                : filteredData.isEmpty
                    ? const Center(
                        child: Text('No categories found.',
                            style: TextStyle(color: AppColors.textMutedLight)))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        itemCount: filteredData.keys.length,
                        itemBuilder: (context, index) {
                          final groupName = filteredData.keys.elementAt(index);
                          final categories = filteredData[groupName] ?? [];

                          return _CategoryGroupSection(
                            groupName: groupName,
                            categories: categories,
                            selectedCategory: widget.selectedCategory,
                            onCategorySelected: widget.onCategorySelected,
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  // ENGINE LỌC DATA TÁCH BIỆT (Pure Logic Helper)
  Map<String, List<CategoryEntity>> _getFilteredGroupedData(
      CategoryViewModel viewModel) {
    final rawData = widget.currentType == 'expense'
        ? viewModel.groupedExpenseCategories
        : viewModel.groupedIncomeCategories;

    if (_searchQuery.trim().isEmpty) return rawData;

    final Map<String, List<CategoryEntity>> filtered = {};
    final query = _searchQuery.trim().toLowerCase();

    for (final entry in rawData.entries) {
      final matches = entry.value
          .where((cat) => cat.name.toLowerCase().contains(query))
          .toList();
      if (matches.isNotEmpty) {
        filtered[entry.key] = matches;
      }
    }
    return filtered;
  }

  // HEADER & NÚT TẠO MỚI
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Select Category',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryLight,
            ),
          ),
          GestureDetector(
            onTap: () => _navigateToCreateCategory(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded, size: 16, color: AppColors.primary),
                  SizedBox(width: 4),
                  Text(
                    'New',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  //  THANH TÌM KIẾM
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Search categories...',
          hintStyle:
              const TextStyle(fontSize: 14, color: AppColors.textMutedLight),
          prefixIcon: const Icon(Icons.search,
              size: 20, color: AppColors.textMutedLight),
          suffixIcon: _searchQuery.isNotEmpty
              ? GestureDetector(
                  onTap: () => setState(() => _searchQuery = ''),
                  child: const Icon(Icons.clear,
                      size: 18, color: AppColors.textMutedLight),
                )
              : null,
          filled: true,
          fillColor: AppColors.dividerLight.withValues(alpha: 0.3),
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
        ),
      ),
    );
  }

  void _navigateToCreateCategory(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final int currentUserId = authProvider.currentUser?.toEntity().id ?? 1;
    final String currentRemoteUid =
        authProvider.currentUser?.toEntity().id?.toString() ?? '';

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateCategoryScreen(
          userId: currentUserId,
          remoteUid: currentRemoteUid,
        ),
      ),
    );
  }
}

// THANH HANDLE TRÊN CÙNG BOTTOM SHEET
class _BottomSheetHandle extends StatelessWidget {
  const _BottomSheetHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.dividerLight,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

// KHỐI PHÂN NHÓM DANH MỤC LỚN
class _CategoryGroupSection extends StatelessWidget {
  final String groupName;
  final List<CategoryEntity> categories;
  final CategoryEntity? selectedCategory;
  final ValueChanged<CategoryEntity> onCategorySelected;

  const _CategoryGroupSection({
    required this.groupName,
    required this.categories,
    this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 10, left: 4),
          child: Text(
            groupName.toUpperCase(),
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textMutedLight,
                letterSpacing: 0.8),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: categories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 10,
            mainAxisExtent: 76,
          ),
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = selectedCategory?.id == category.id;

            return _CategoryGridItem(
              category: category,
              isSelected: isSelected,
              onTap: () {
                onCategorySelected(category);
                Navigator.pop(context);
              },
            );
          },
        ),
      ],
    );
  }
}

// ITEM ICON DANH MỤC ĐƠN
class _CategoryGridItem extends StatelessWidget {
  final CategoryEntity category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryGridItem({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = Color(category.colorValue);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: baseColor.withValues(alpha: 0.14),
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: AppColors.primary, width: 2)
                  : null,
            ),
            child: Icon(
              IconData(
                category.iconCodePoint,
                fontFamily: category.iconFontFamily ?? 'MaterialIcons',
              ),
              color: baseColor,
              size: 22,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            category.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color:
                  isSelected ? AppColors.primary : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
