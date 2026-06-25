import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';

class CategoryPickerSheet extends StatelessWidget {
  final List<dynamic> categories;
  final dynamic selectedCategory;
  final ValueChanged<dynamic> onCategorySelected;

  const CategoryPickerSheet({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(AppSizes.lg)),
      ),
      padding: EdgeInsets.only(
        top: AppSizes.md,
        left: AppSizes.md,
        right: AppSizes.md,
        bottom: bottomPadding + AppSizes.sm,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. SLIVER HEADER: Thanh kéo ngang và Tiêu đề
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.md),
                const Text(
                  'Select Category',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSizes.md),
              ],
            ),
          ),

          // 2. SLIVER GRID: Danh sách danh mục dạng khối phẳng Borderless trơn láng
          SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: AppSizes.md,
              crossAxisSpacing: AppSizes.sm,
              childAspectRatio: 0.85,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final cat = categories[index];
                final isSelected = selectedCategory?.id == cat.id;
                final catColor = Color(cat.colorValue ?? 0xFF9E9E9E);

                return GestureDetector(
                  onTap: () {
                    onCategorySelected(cat);
                    Navigator.pop(context);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      // Sử dụng khối màu nền mịn để phân biệt trạng thái thay vì dùng viền nét cứng
                      color: isSelected
                          ? catColor.withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppSizes.md),
                      border: null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundColor: isSelected
                              ? catColor
                              : catColor.withValues(alpha: 0.15),
                          child: Icon(
                            IconData(
                              cat.iconCodePoint ?? 57574,
                              fontFamily: cat.iconFontFamily ?? 'MaterialIcons',
                            ),
                            color: isSelected ? Colors.white : catColor,
                          ),
                        ),
                        const SizedBox(height: AppSizes.xs),
                        Text(
                          cat.name,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              childCount: categories.length,
            ),
          ),

          // 3. SLIVER PADDING: Khoảng cách đệm an toàn kịch sàn
          const SliverToBoxAdapter(
            child: SizedBox(height: AppSizes.lg),
          ),
        ],
      ),
    );
  }
}
