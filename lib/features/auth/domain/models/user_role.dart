enum UserRole {
  guest,
  customer,
  admin;

  bool get isAdmin => this == UserRole.admin;

  static UserRole fromApi(String value) {
    final normalized = value.trim().toLowerCase();

    switch (normalized) {
      case 'администратор':
      case 'admin':
        return UserRole.admin;
      case 'покупатель':
      case 'customer':
      case 'user':
        return UserRole.customer;
      case 'гость':
      case 'guest':
        return UserRole.guest;
      default:
        return UserRole.guest;
    }
  }

  String toApiValue() {
    switch (this) {
      case UserRole.admin:
        return 'Администратор';
      case UserRole.customer:
        return 'Покупатель';
      case UserRole.guest:
        return 'Гость';
    }
  }
}