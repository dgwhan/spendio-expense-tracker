import 'package:spend_io_app/features/auth/domain/repositories/auth_repository.dart';

class CheckWalletUseCase {
  final AuthRepository repository;

  CheckWalletUseCase(this.repository);

  /// Kiểm tra xem email có dữ liệu ví trong Firestore không
  /// Nếu có -> user đã từng onboard (bỏ qua bước onboarding)
  /// Nếu không -> user mới, cần onboard
  Future<bool> call(String email) async {
    return await repository.checkWalletExists(email);
  }
}
