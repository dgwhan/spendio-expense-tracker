/// application user model
class UserModel {
  final String id;
  final String email;
  final String password;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.password,
    required this.createdAt,
  });

  /// convert object to map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// create object from map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  /// clone object with new values
  UserModel copyWith({
    String? id,
    String? email,
    String? password,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}