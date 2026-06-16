import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_colors.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';

class CategoryPickerSheet extends StatelessWidget {
  final List<dynamic>
      categories; // Nhận danh sách CategoryEntity từ module của bạn
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

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(AppSizes.lg)),
      ),
      padding: const EdgeInsets.only(
        top: AppSizes.md,
        left: AppSizes.md,
        right: AppSizes.md,
      ),
      // Ràng buộc chiều cao tối đa của Bottom Sheet bằng 60% màn hình
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
                      color: Colors.grey.withOpacity(0.3),
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

          // 2. SLIVER GRID: Hiển thị danh sách các Category động
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
                      color: isSelected
                          ? catColor.withOpacity(0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppSizes.md),
                      border: Border.all(
                        color: isSelected ? catColor : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundColor: catColor.withOpacity(0.2),
                          child: Icon(
                            IconData(
                              cat.iconCodePoint ?? 57574,
                              fontFamily: cat.iconFontFamily ?? 'MaterialIcons',
                            ),
                            color: catColor,
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
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
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

          // 3. SLIVER PADDING: Tạo khoảng trống an toàn dưới đáy Sheet khi cuộn kịch sàn
          const SliverToBoxAdapter(
            child: SizedBox(height: AppSizes.lg),
          ),
        ],
      ),
    );
  }
}
