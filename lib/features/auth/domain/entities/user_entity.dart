class UserEntity {
  final int? id;
  final String name;
  final String email;
  final String password;

  const UserEntity({
    this.id,
    required this.name,
    required this.email,
    required this.password,
  });
}