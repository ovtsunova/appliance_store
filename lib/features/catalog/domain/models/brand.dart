import '../../../../core/utils/json_parsers.dart';

class Brand {
  final int id;
  final String name;
  final String countryOfOrigin;
  final String? contactInfo;

  const Brand({
    required this.id,
    required this.name,
    required this.countryOfOrigin,
    this.contactInfo,
  });

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: JsonParsers.toInt(json['id']),
      name: JsonParsers.toStringValue(json['name']),
      countryOfOrigin: JsonParsers.toStringValue(json['countryOfOrigin']),
      contactInfo: JsonParsers.toNullableString(json['contactInfo']),
    );
  }
}