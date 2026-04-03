import '../../../../core/utils/json_parsers.dart';

class Address {
  final int? id;
  final String country;
  final String city;
  final String street;
  final String house;
  final String? apartment;
  final String postalCode;

  const Address({
    this.id,
    required this.country,
    required this.city,
    required this.street,
    required this.house,
    this.apartment,
    required this.postalCode,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] == null ? null : JsonParsers.toInt(json['id']),
      country: JsonParsers.toStringValue(json['country']),
      city: JsonParsers.toStringValue(json['city']),
      street: JsonParsers.toStringValue(json['street']),
      house: JsonParsers.toStringValue(json['house']),
      apartment: JsonParsers.toNullableString(json['apartment']),
      postalCode: JsonParsers.toStringValue(json['postalCode']),
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'country': country,
      'city': city,
      'street': street,
      'house': house,
      'apartment': apartment ?? '',
      'postalCode': postalCode,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'country': country,
      'city': city,
      'street': street,
      'house': house,
      'apartment': apartment ?? '',
      'postalCode': postalCode,
    };
  }
}