const String userContextKey = 'user_context';

class UserContext {
  final int accountId;
  final int userId;
  final String email;
  final String role;
  final String fullName;

  const UserContext({
    required this.accountId,
    required this.userId,
    required this.email,
    required this.role,
    required this.fullName,
  });

  factory UserContext.fromMap(Map<String, dynamic> map) {
    return UserContext(
      accountId: map['accountId'] as int,
      userId: map['userId'] as int,
      email: map['email'] as String,
      role: map['role'] as String,
      fullName: map['fullName'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'accountId': accountId,
      'userId': userId,
      'email': email,
      'role': role,
      'fullName': fullName,
    };
  }

  bool get isAdmin => role == 'Администратор';
  bool get isCustomer => role == 'Покупатель';
}