import 'user_role.dart';

class AppUser {
  final int accountId;
  final int userId;
  final String email;
  final String fullName;
  final String? phoneNumber;
  final UserRole role;
  final bool isBlocked;

  const AppUser({
    required this.accountId,
    required this.userId,
    required this.email,
    required this.fullName,
    required this.role,
    required this.isBlocked,
    this.phoneNumber,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      accountId: _toInt(json['accountId'] ?? json['id']),
      userId: _toInt(json['userId'] ?? json['id']),
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      role: UserRole.fromApi(json['role'] as String),
      isBlocked: (json['isBlocked'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accountId': accountId,
      'userId': userId,
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'role': role.toApiValue(),
      'isBlocked': isBlocked,
    };
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.parse(value);
    throw FormatException('Не удалось преобразовать "$value" в int');
  }
}