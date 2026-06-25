import 'package:spend_io_app/features/auth/domain/entities/user_entity.dart';
import 'package:spend_io_app/features/auth/domain/repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<bool> call(UserEntity user) {
    return repository.register(user);
  }
}
