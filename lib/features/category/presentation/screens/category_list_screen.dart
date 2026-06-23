import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_header.dart';
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
    final categoryVM = context.read<CategoryViewModel>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Category', style: AppTextStyles.headingMedium),
        content: Text(
          'Are you sure you want to delete "${category.name}"?',
          style: AppTextStyles.bodyNormal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: AppTextStyles.buttonLabel.copyWith(color: Colors.grey)),
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
            child: Text('Delete',
                style:
                    AppTextStyles.buttonLabel.copyWith(color: AppColors.error)),
          )
        ],
      ),
    );
  }

  Widget _buildCategoryListView(Map<String, List<CategoryEntity>> groupedData) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (groupedData.isEmpty) {
      return Center(
        child: Text(
          'No categories found.',
          style: AppTextStyles.bodyNormal.copyWith(
            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
          ),
        ),
      );
    }

    final surfaceColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final primaryTextColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedTextColor =
        isDark ? AppColors.textMutedDark : AppColors.textMutedLight;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md, vertical: AppSizes.sm),
      physics: const BouncingScrollPhysics(),
      itemCount: groupedData.keys.length,
      itemBuilder: (context, index) {
        final groupName = groupedData.keys.elementAt(index);
        final categories = groupedData[groupName] ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề phân nhóm cứng cáp, tinh tế hơn
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
              child: Text(
                groupName.toUpperCase(),
                style: AppTextStyles.overline.copyWith(color: mutedTextColor),
              ),
            ),

            // Container bọc phẳng thay vì các khối Card thô cũ
            Container(
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  width: 1,
                ),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categories.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  thickness: 1,
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  indent: 56,
                ),
                itemBuilder: (context, catIdx) {
                  final category = categories[catIdx];
                  final baseColor = Color(category.colorValue);

                  return ListTile(
                    onTap: null, // Giữ tĩnh theo đúng logic yêu cầu
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: baseColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
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
                      style: AppTextStyles.bodyNormal.copyWith(
                        fontWeight: FontWeight.w600,
                        color: primaryTextColor,
                      ),
                    ),
                    trailing: category.userId != 0
                        ? IconButton(
                            splashRadius: 20,
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: AppColors.error,
                              size: 20,
                            ),
                            onPressed: () => _handleDeleteCategory(category),
                          )
                        : Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.surfaceSecondaryDark
                                  : AppColors.surfaceSecondaryLight,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Text(
                              'System',
                              style: AppTextStyles.overline.copyWith(
                                color: mutedTextColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                  );
                },
              ),
            ),
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
      // NÂNG CẤP: Sử dụng widget AppHeader chuẩn cho toàn app thay thế AppBar thô sơ
      appBar: AppHeader(
        title: 'Manage Categories',
        showBack: true,
        onBack: () => Navigator.pop(context),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'New Category',
            onPressed: () async {
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

              if (result == true && context.mounted) {
                categoryVM.loadCategories(widget.userId);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Khối TabBar được tinh chỉnh màu sắc theo Token hệ thống
          Container(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor:
                  isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
              indicatorColor: AppColors.primary,
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: AppTextStyles.buttonLabel.copyWith(fontSize: 14),
              unselectedLabelStyle:
                  AppTextStyles.bodyNormal.copyWith(fontSize: 14),
              tabs: const [
                Tab(text: 'Expenses'),
                Tab(text: 'Incomes'),
              ],
            ),
          ),
          Expanded(
            child: viewModel.state.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary))
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildCategoryListView(
                          viewModel.groupedExpenseCategories),
                      _buildCategoryListView(viewModel.groupedIncomeCategories),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
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

          if (result == true && context.mounted) {
            categoryVM.loadCategories(widget.userId);
          }
        },
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        icon: const Icon(Icons.add_rounded, size: 20),
        label: Text('Add Custom',
            style: AppTextStyles.buttonLabel
                .copyWith(color: AppColors.white, fontSize: 13)),
      ),
    );
  }
}
