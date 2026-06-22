import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';

enum CategorySortOption { nameAZ, newest, oldest }

class CategoryListSubheader extends StatelessWidget {
  final CategorySortOption currentSort;
  final Function(CategorySortOption) onSortSelected;

  const CategoryListSubheader({
    super.key,
    required this.currentSort,
    required this.onSortSelected,
  });

  String _getSortLabel(CategorySortOption option) {
    switch (option) {
      case CategorySortOption.nameAZ:
        return 'A - Z';
      case CategorySortOption.newest:
        return 'Newest';
      case CategorySortOption.oldest:
        return 'Oldest';
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<CategorySortOption>(
      onSelected: onSortSelected,
      constraints: const BoxConstraints(minWidth: 160),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[800]
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.filter_list_rounded,
                size: 16, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(
              _getSortLabel(currentSort),
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary),
            ),
          ],
        ),
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: CategorySortOption.nameAZ,
          child: Row(children: [
            Icon(Icons.sort_by_alpha_rounded, size: 16),
            SizedBox(width: 8),
            Text('Alphabetical (A-Z)')
          ]),
        ),
        const PopupMenuItem(
          value: CategorySortOption.newest,
          child: Row(children: [
            Icon(Icons.arrow_upward_rounded, size: 16),
            SizedBox(width: 8),
            Text('Newest Created')
          ]),
        ),
        const PopupMenuItem(
          value: CategorySortOption.oldest,
          child: Row(children: [
            Icon(Icons.arrow_downward_rounded, size: 16),
            SizedBox(width: 8),
            Text('Oldest Created')
          ]),
        ),
      ],
    );
  }
}
