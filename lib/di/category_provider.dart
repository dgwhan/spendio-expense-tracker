import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:sqflite/sqflite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Import các thành phần của module Category theo đúng cấu trúc thư mục của bạn
import 'package:spend_io_app/features/category/data/datasources/category_local_data_source.dart';
import 'package:spend_io_app/features/category/data/datasources/category_remote_data_source.dart';
import 'package:spend_io_app/features/category/data/repositories/category_repository_impl.dart';
import 'package:spend_io_app/features/category/domain/repositories/category_repository.dart';
import 'package:spend_io_app/features/category/presentation/viewmodels/category_viewmodel.dart';

class CategoryProvider {
  CategoryProvider._();

  /// Bundles all category-related dependency injection states
  static List<SingleChildWidget> get providers => [
        // 1. Inject Local Data Source
        // Yêu cầu `Future<Database>` đã được cung cấp ở đỉnh cây AppProviders
        ProxyProvider<Future<Database>, CategoryLocalDataSource>(
          update: (_, dbFuture, __) =>
              CategoryLocalDataSourceImpl(database: dbFuture),
        ),

        // 2. Inject Remote Data Source
        Provider<CategoryRemoteDataSource>(
          create: (_) => CategoryRemoteDataSourceImpl(
            firestore: FirebaseFirestore.instance,
          ),
        ),

        // 3. Inject Repository (Kết hợp cả Local và Remote Data Sources)
        ProxyProvider2<CategoryLocalDataSource, CategoryRemoteDataSource,
            CategoryRepository>(
          update: (_, localSrc, remoteSrc, __) => CategoryRepositoryImpl(
            localDataSource: localSrc,
            remoteDataSource: remoteSrc,
          ),
        ),

        // 4. Inject ViewModel sử dụng ChangeNotifierProxyProvider chuẩn chỉ
        // Đảm bảo nếu Repository có bị làm mới (re-create), ViewModel vẫn nhận được bản cập nhật
        ChangeNotifierProxyProvider<CategoryRepository, CategoryViewModel>(
          create: (context) => CategoryViewModel(
            repository: context.read<CategoryRepository>(),
          ),
          update: (_, repo, previous) {
            if (previous == null) {
              return CategoryViewModel(repository: repo);
            }
            // Gọi hàm cập nhật repo bên trong ViewModel (nếu có) để tránh rò rỉ dữ liệu cũ
            previous.updateRepository(repo);
            return previous;
          },
        ),
      ];
}
