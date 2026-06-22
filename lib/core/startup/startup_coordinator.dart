import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:spend_io_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:spend_io_app/features/category/domain/repositories/category_repository.dart';
import 'package:spend_io_app/features/category/presentation/viewmodels/category_viewmodel.dart';
import 'package:spend_io_app/features/transaction/domain/usecases/initialize_transaction_categories_usecase.dart';
import 'package:spend_io_app/features/wallet/domain/usecases/check_wallet_initialization_usecase.dart';
import 'package:spend_io_app/features/transaction/presentation/viewmodels/transaction_viewmodel.dart';
import 'package:spend_io_app/features/wallet/presentation/viewmodels/wallet_viewmodel.dart';
import 'package:spend_io_app/features/profile/presentation/viewmodels/profile_viewmodel.dart';
import 'startup_result.dart';

///Điều phối và kiểm soát toàn bộ luồng dữ liệu khi khởi động ứng dụng (Splash/Startup Screen).
///Chịu trách nhiệm kiểm tra Session, cấu hình DB cục bộ và tiền tải (preload) dữ liệu lên các ViewModel.
class StartupCoordinator {
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final CheckWalletInitializationUseCase checkWalletInitializationUseCase;
  final AuthProvider authProvider;

  StartupCoordinator({
    required this.getCurrentUserUseCase,
    required this.checkWalletInitializationUseCase,
    required this.authProvider,
  });

  Future<StartupResult> resolve(BuildContext context) async {
    debugPrint("[STARTUP DIAGNOSTIC] === BẮT ĐẦU TIẾN TRÌNH KHỞI ĐỘNG APP ===");

    //ĐỌC TRƯỚC THAM CHIẾU

    //Đọc tất cả các ViewModel và Repository cần thiết ngay từ đầu luồng đồng bộ.
    //Việc này giải quyết triệt để lỗi "use_build_context_synchronously", đảm bảo
    //an toàn khi gọi data layer sau các khoảng nghỉ bất đồng bộ (async gaps).
    final categoryRepository = context.read<CategoryRepository>();
    final profileVM = context.read<ProfileViewModel>();
    final walletVM = context.read<WalletViewModel>();
    final categoryVM = context.read<CategoryViewModel>();
    final transactionVM = context.read<TransactionViewModel>();

    try {
      //SEED DATA OFFLINE (KHỞI TẠO DANH MỤC MẶC ĐỊNH)
      // Nạp các danh mục mặc định vào SQLite ngay khi mở app để UI không bị null icon/color.
      // Luồng này chạy cô lập trong try-catch riêng để nếu lỗi DB, app vẫn có thể chạy tiếp.
      debugPrint("[STARTUP DIAGNOSTIC] Khởi tạo danh mục mặc định...");
      try {
        final initCategoriesUseCase =
            InitializeTransactionCategoriesUseCase(categoryRepository);
        await initCategoriesUseCase.call();
      } catch (e) {
        debugPrint("[STARTUP DIAGNOSTIC] Lỗi khởi tạo danh mục mặc định: $e");
      }

      //LOCAL SESSION CHECK (KIỂM TRA THÔNG TIN USER CỤC BỘ)
      // Gọi UseCase lấy thông tin cơ bản của User đã lưu dưới máy (SQLite/Preferences).
      // Giới hạn thời gian xử lý tối đa 3 giây để tránh treo app tại màn hình loading.
      debugPrint("[STARTUP DIAGNOSTIC] Đang gọi getCurrentUserUseCase()...");
      final user = await getCurrentUserUseCase().timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          debugPrint(
              "[STARTUP WORKER] Timeout: getCurrentUserUseCase bị treo -> Hướng về Login");
          return null;
        },
      );

      debugPrint(
          "[STARTUP DIAGNOSTIC] Kết quả User: ${user?.email ?? 'RỖNG'} (ID: ${user?.id ?? 'NULL'})");

      // Bẻ luồng về Login nếu không tìm thấy bất kỳ dữ liệu tài khoản cục bộ nào.
      if (user == null || user.id == null) {
        debugPrint(
            "[STARTUP DIAGNOSTIC] Không tìm thấy session User -> Hướng về LOGIN");
        authProvider.setCurrentUser(null);
        return StartupResult.login;
      }

      //XÁC THỰC VỚI FIREBASE AUTH
      // Đảm bảo rằng token/session đồng bộ từ Firebase Auth vẫn còn hiệu lực thực tế.
      // Nếu mất tín hiệu đồng bộ từ máy chủ (Firebase trả về rỗng), yêu cầu login lại.
      debugPrint("[STARTUP DIAGNOSTIC] Kiểm tra Firebase Auth Instance...");
      final firebaseUser = fb.FirebaseAuth.instance.currentUser;
      final remoteUid = firebaseUser?.uid ?? '';
      debugPrint("[STARTUP DIAGNOSTIC] Firebase Remote UID: '$remoteUid'");

      if (remoteUid.trim().isEmpty) {
        debugPrint(
            "[STARTUP DIAGNOSTIC] Firebase Session rỗng -> Hướng về LOGIN");
        authProvider.setCurrentUser(null);
        return StartupResult.login;
      }

      // KIỂM TRA TRẠNG THÁI KHỞI TẠO VÍ / ONBOARDING
      // Xác định xem user này là user mới hoàn toàn hay cũ bằng cách check cấu trúc ví.
      // Nếu quá trình kiểm tra mất hơn 3 giây, ép fallback về false để xử lý an toàn.
      debugPrint(
          "[STARTUP DIAGNOSTIC] Đang gọi checkWalletInitializationUseCase...");
      final int nonNullUserId = user.id!;
      final isInitialized =
          await checkWalletInitializationUseCase(nonNullUserId).timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          debugPrint(
              "[STARTUP WORKER] Timeout: CheckWalletInitialization bị treo -> Ép về Onboarding");
          return false;
        },
      );

      debugPrint(
          "[STARTUP DIAGNOSTIC] Trạng thái ví khởi tạo: $isInitialized, Onboarding hoàn thành: ${user.onboardingCompleted}");

      //TIỀN TẢI DỮ LIỆU & ĐIỀU HƯỚNG HOME
      // Nếu cấu trúc ví hợp lệ hoặc user đã hoàn thành onboarding, tiến hành tiền tải
      // toàn bộ state lên RAM để khi vào Home, giao diện lập tức có dữ liệu hiển thị.
      if (isInitialized || user.onboardingCompleted) {
        // Đồng bộ hóa thực thể User hiện tại vào hệ thống AuthProvider toàn cục.
        if (context.mounted) {
          debugPrint(
              "[STARTUP DIAGNOSTIC] Bước 4: Đồng bộ duy nhất qua AuthProvider...");
          authProvider.setCurrentUser(user);
        }

        // Tải thông tin Profile cá nhân.
        await profileVM.loadCurrentUser();

        // Khởi tạo các tham số cơ bản của Ví (Số dư, tài sản mặc định).
        debugPrint(
            "[STARTUP DIAGNOSTIC] Chờ luồng Ví nạp xong cấu trúc cơ sở ngầm...");
        await walletVM.initialize().timeout(
          const Duration(seconds: 4),
          onTimeout: () {
            debugPrint(
                "[STARTUP WARNING]: Khởi tạo Ví mất quá nhiều thời gian, bỏ qua để vào Home.");
          },
        );

        // Đổ toàn bộ danh mục chi tiêu/thu nhập của User lên RAM.
        debugPrint(
            "[STARTUP DIAGNOSTIC] Đang nạp danh mục qua categoryViewModel...");
        await categoryVM.loadCategories(nonNullUserId).timeout(
          const Duration(seconds: 4),
          onTimeout: () {
            debugPrint(
                "[STARTUP WARNING]: Khởi tạo Danh mục mất quá nhiều thời gian, bỏ qua.");
          },
        );

        // Nạp lịch sử giao dịch gần đây. Chặn đứng (Throw) nếu hàm này bị deadlock/treo vô hạn.
        debugPrint(
            "[STARTUP DIAGNOSTIC] Đang nạp lịch sử giao dịch qua transactionViewModel...");
        await transactionVM.loadAllTransactions().timeout(
          const Duration(seconds: 4),
          onTimeout: () {
            debugPrint(
                "[CRITICAL BUG FOUND] Hàm transactionViewModel.loadAllTransactions() BỊ TREO HOÀN TOÀN!");
            throw TimeoutException("Treo tại TransactionVM");
          },
        );

        debugPrint("[STARTUP DIAGNOSTIC] Load lịch sử giao dịch THÀNH CÔNG!");
        debugPrint(
            "[STARTUP DIAGNOSTIC] === LUỒNG ĐI QUA SẠCH SẼ -> ĐIỀU HƯỚNG VỀ HOME ===");
        return StartupResult.home;
      }

      // Ngược lại, nếu chưa thỏa điều kiện, ép thực hiện chuỗi thiết lập Onboarding.
      debugPrint("[STARTUP DIAGNOSTIC] Điều hướng về ONBOARDING");
      return StartupResult.onboarding;
    } catch (e, stack) {
      // XỬ LÝ LỖI HỆ THỐNG
      // Điểm bọc an toàn cuối cùng. Bất kỳ lỗi logic phát sinh ngoài tầm kiểm soát (Crash, DB lock, v.v.)
      // đều sẽ được bắt lại ở đây, in vết StackTrace và đẩy User an toàn ra màn hình Login.
      debugPrint("[STARTUP CRASH REPORT] Lỗi hệ thống: $e");
      debugPrintStack(stackTrace: stack);
      authProvider.setCurrentUser(null);
      return StartupResult.login;
    }
  }
}
