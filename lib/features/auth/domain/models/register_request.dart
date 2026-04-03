class RegisterRequest {
  final String lastName;
  final String firstName;
  final String patronymic;
  final String phoneNumber;
  final String email;
  final String password;

  const RegisterRequest({
    required this.lastName,
    required this.firstName,
    required this.patronymic,
    required this.phoneNumber,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'lastName': lastName.trim(),
      'firstName': firstName.trim(),
      'patronymic': patronymic.trim(),
      'phoneNumber': phoneNumber.trim(),
      'email': email.trim(),
      'password': password,
    };
  }
}