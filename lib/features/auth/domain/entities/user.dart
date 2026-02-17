import 'role.dart';

/// Entidad de usuario
class User {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? photoUrl;
  final Role role;
  final String? zone;
  final String? timezone;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.photoUrl,
    required this.role,
    this.zone,
    this.timezone,
  });

  bool get isAdmin => role == Role.admin;
  bool get isOperator => role == Role.operator;

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? photoUrl,
    Role? role,
    String? zone,
    String? timezone,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      zone: zone ?? this.zone,
      timezone: timezone ?? this.timezone,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, role: $role)';
  }
}
