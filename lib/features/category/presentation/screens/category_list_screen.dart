import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../domain/entities/category_entity.dart';
import '../viewmodels/category_viewmodel.dart';
import 'create_category_screen.dart';

class CategoryListScreen extends StatefulWidget {
  final int userId;
  final String remoteUid;

  const CategoryListScreen({
    super.key,
    required this.userId,
    required this.remoteUid,
  });

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Nạp dữ liệu từ database vào RAM ngay khi mở màn hình quản lý
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        context.read<CategoryViewModel>().loadCategories(widget.userId);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleDeleteCategory(CategoryEntity category) {
    // TRƯỚC ASYNC GAP: Đọc sẵn instance ViewModel ra biến cục bộ
    final categoryVM = context.read<CategoryViewModel>();

    // Hiển thị hộp thoại xác nhận trước khi xóa
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);

              Navigator.pop(ctx);

              final errorMessage = await categoryVM.deleteCategory(
                categoryId: category.id,
                remoteUid: widget.remoteUid,
                userId: widget.userId,
              );

              if (errorMessage == null) {
                messenger.showSnackBar(
                  const SnackBar(
                      content: Text('Category deleted successfully.')),
                );
              } else {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(errorMessage),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child:
                const Text('Delete', style: TextStyle(color: AppColors.error)),
          )
        ],
      ),
    );
  }

  Widget _buildCategoryListView(Map<String, List<CategoryEntity>> groupedData) {
    if (groupedData.isEmpty) {
      return const Center(child: Text('No categories found.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.md),
      itemCount: groupedData.keys.length,
      itemBuilder: (context, index) {
        final groupName = groupedData.keys.elementAt(index);
        final categories = groupedData[groupName] ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề Section phân nhóm cứng
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Text(
                groupName,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMutedLight,
                ),
              ),
            ),

            // Danh sách các danh mục con bên trong nhóm
            Card(
              elevation: 0,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.surfaceSecondaryDark
                  : AppColors.surfaceSecondaryLight,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.md)),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categories.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, indent: 56),
                itemBuilder: (context, catIdx) {
                  final category = categories[catIdx];
                  final baseColor = Color(category.colorValue);

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: baseColor.withValues(alpha: 0.15),
                      child: Icon(
                        IconData(
                          category.iconCodePoint,
                          fontFamily:
                              category.iconFontFamily ?? 'MaterialIcons',
                        ),
                        color: baseColor,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      category.name,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                    trailing: category.userId != 0
                        ? IconButton(
                            icon: const Icon(Icons.delete_outline_rounded,
                                color: AppColors.error, size: 20),
                            onPressed: () => _handleDeleteCategory(category),
                          )
                        : const Text(
                            'Default',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textMutedLight,
                            ),
                          ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSizes.md),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final viewModel = context.watch<CategoryViewModel>();

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
          'Manage Categories',
          style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: const [
            Tab(text: 'Expenses'),
            Tab(text: 'Incomes'),
          ],
        ),
      ),
      body: viewModel.state.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildCategoryListView(viewModel.groupedExpenseCategories),
                _buildCategoryListView(viewModel.groupedIncomeCategories),
              ],
            ),

      // Nút tròn FloatingActionButton góc phải để thêm danh mục custom nhanh
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // TRƯỚC ASYNC GAP: Đọc sẵn ViewModel ra ngoài trước khi điều hướng
          final categoryVM = context.read<CategoryViewModel>();

          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreateCategoryScreen(
                userId: widget.userId,
                remoteUid: widget.remoteUid,
              ),
            ),
          );

          // SAU ASYNC GAP: Kiểm tra tính toàn vẹn của context.mounted
          if (result == true && context.mounted) {
            categoryVM.loadCategories(widget.userId);
          }
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Custom'),
      ),
    );
  }
}
