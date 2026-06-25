import 'package:spend_io_app/features/auth/domain/entities/user_entity.dart';
import 'package:spend_io_app/features/auth/domain/repositories/auth_repository.dart';

/// Use case: Sign in the user with Google.
///
/// Sits in the domain layer and delegates to [AuthRepository].
/// Returns `null` if the user cancelled the picker, or a [UserEntity] on success.
class SignInWithGoogleUseCase {
  final AuthRepository repository;

  const SignInWithGoogleUseCase(this.repository);

  Future<UserEntity?> call() => repository.signInWithGoogle();
}
