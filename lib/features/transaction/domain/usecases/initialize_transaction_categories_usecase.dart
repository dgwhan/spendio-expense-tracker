import 'package:flutter/material.dart';
import 'package:spend_io_app/core/utils/app_default_categories.dart';
import 'package:spend_io_app/features/category/domain/entities/category_entity.dart';
import 'package:spend_io_app/features/category/domain/repositories/category_repository.dart';

class InitializeTransactionCategoriesUseCase {
  final CategoryRepository repository;

  InitializeTransactionCategoriesUseCase(this.repository);

  /// Kích hoạt nạp danh sách danh mục cấu hình hệ thống vào SQLite local
  /// Hàm trả về [bool]: [true] nếu nạp mới lần đầu, [false] nếu đã được nạp trước đó.
  Future<bool> call() async {
    debugPrint('[UseCase] Thực thi InitializeTransactionCategoriesUseCase...');

    try {
      // Kiểm tra trạng thái dữ liệu hiện tại dưới SQLite local
      final List<CategoryEntity> existingCategories =
          await repository.getAllCategories();

      // Nếu cơ sở dữ liệu đã có danh mục -> Bỏ qua, tránh ghi đè dữ liệu custom của User
      if (existingCategories.isNotEmpty) {
        debugPrint(
            '[UseCase] Danh mục đã tồn tại trong hệ thống. Hủy luồng khởi tạo.');
        return false;
      }

      debugPrint(
          '[UseCase] Không tìm thấy dữ liệu cũ. Bắt đầu nạp danh mục mặc định...');

      // Lấy danh mục hệ thống từ file Utillities
      final List<CategoryEntity> defaultCategories =
          AppDefaultCategories.allDefaultCategories;

      if (defaultCategories.isEmpty) {
        debugPrint('[UseCase] Cảnh báo: Mảng danh mục mặc định trống rỗng.');
        return false;
      }

      // Sử dụng Future.wait để kích hoạt lưu đồng thời
      await Future.wait(
        defaultCategories
            .map((category) => repository.insertCategory(category)),
      );

      debugPrint('[UseCase] Khởi tạo đống danh mục hệ thống thành công');
      return true;
    } catch (e, stackTrace) {
      debugPrint(
          '[UseCase] Lỗi nghiêm trọng trong quá trình khởi tạo dữ liệu danh mục: $e');
      debugPrintStack(stackTrace: stackTrace);

      // Bắn lỗi ra ngoài để tầng Presentation (Splash/Auth)
      throw Exception('Failed to initialize system categories: $e');
    }
  }
}
