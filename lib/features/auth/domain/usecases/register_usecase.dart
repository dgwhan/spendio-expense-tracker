//chứa nhiệm vụ của chức năng đó, file này sẽ gọi đến auth_repository để thực hiện lệnh dky 

import '../repositories/auth_repository.dart';
import '../entities/user_entity.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<bool> call(UserEntity user) {
    return repository.register(user);
  }
}