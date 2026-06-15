class ProfileUserEntity {
  final String id;
  final String email;
  final String displayName;
  final String? occupation;

  const ProfileUserEntity({
    required this.id,
    required this.email,
    required this.displayName,
    this.occupation,
  });
}
