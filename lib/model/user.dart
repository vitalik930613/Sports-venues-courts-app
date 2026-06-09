enum UserRole { admin, owner, customer }

class User {
  final int id;
  final String name;
  final String email;
  final String phone;
  final DateTime birthDate;
  final UserRole role;
  final bool isPremium;
  final DateTime? emailVerifiedAt;
  final String? photo;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.birthDate,
    required this.role,
    required this.isPremium,
    this.emailVerifiedAt,
    this.photo,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      birthDate: DateTime.parse(json['birth_date'] as String),
      role: _roleFromString(json['role'] as String),
      isPremium: json['is_premium'] as bool? ?? false,
      emailVerifiedAt: json['email_verified_at'] != null
          ? DateTime.parse(json['email_verified_at'] as String)
          : null,
      photo: json['photo'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'birth_date': birthDate.toIso8601String().split('T').first,
      'role': _roleToString(role),
      'is_premium': isPremium,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'photo': photo,
    };
  }

  static UserRole _roleFromString(String value) {
    switch (value) {
      case 'admin':
        return UserRole.admin;
      case 'owner':
        return UserRole.owner;
      default:
        return UserRole.customer;
    }
  }

  static String _roleToString(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'admin';
      case UserRole.owner:
        return 'owner';
      case UserRole.customer:
        return 'customer';
    }
  }
}
