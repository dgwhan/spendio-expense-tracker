import 'package:spend_io_app/features/auth/domain/repositories/auth_repository.dart';

class CheckEmailUseCase {
  final AuthRepository repository;

  CheckEmailUseCase(this.repository);

  Future<bool> call(String email) async {
    return await repository.checkEmailExists(email);
  }
}