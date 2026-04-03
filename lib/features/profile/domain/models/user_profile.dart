import '../../../../core/utils/json_parsers.dart';
import 'address.dart';

class UserProfile {
  final int accountId;
  final int userId;
  final String email;
  final String role;
  final String fullName;
  final String lastName;
  final String firstName;
  final String patronymic;
  final String phoneNumber;
  final bool isBlocked;
  final String? registrationDate;
  final List<Address> addresses;

  const UserProfile({
    required this.accountId,
    required this.userId,
    required this.email,
    required this.role,
    required this.fullName,
    required this.lastName,
    required this.firstName,
    required this.patronymic,
    required this.phoneNumber,
    required this.isBlocked,
    this.registrationDate,
    required this.addresses,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      accountId: JsonParsers.toInt(json['accountId']),
      userId: JsonParsers.toInt(json['userId']),
      email: JsonParsers.toStringValue(json['email']),
      role: JsonParsers.toStringValue(json['role']),
      fullName: JsonParsers.toStringValue(json['fullName']),
      lastName: JsonParsers.toStringValue(json['lastName']),
      firstName: JsonParsers.toStringValue(json['firstName']),
      patronymic: JsonParsers.toStringValue(json['patronymic']),
      phoneNumber: JsonParsers.toStringValue(json['phoneNumber']),
      isBlocked: JsonParsers.toBool(json['isBlocked']),
      registrationDate: JsonParsers.toNullableString(json['registrationDate']),
      addresses: (json['addresses'] as List<dynamic>? ?? [])
          .map((item) => Address.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'email': email,
      'lastName': lastName,
      'firstName': firstName,
      'patronymic': patronymic,
      'phoneNumber': phoneNumber,
    };
  }

  UserProfile copyWith({
    String? email,
    String? lastName,
    String? firstName,
    String? patronymic,
    String? phoneNumber,
    List<Address>? addresses,
  }) {
    return UserProfile(
      accountId: accountId,
      userId: userId,
      email: email ?? this.email,
      role: role,
      fullName: fullName,
      lastName: lastName ?? this.lastName,
      firstName: firstName ?? this.firstName,
      patronymic: patronymic ?? this.patronymic,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isBlocked: isBlocked,
      registrationDate: registrationDate,
      addresses: addresses ?? this.addresses,
    );
  }
}