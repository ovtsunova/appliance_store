class ApiConstants {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080/api',
  );

  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String forgotPassword = '/auth/forgot-password';
  static const String me = '/auth/me';
  static const String logout = '/auth/logout';

  static const String products = '/products';
  static String productById(int id) => '/products/$id';
}