import '../../../../core/utils/json_parsers.dart';

class PaymentType {
  final int id;
  final String typeName;
  final String? description;

  const PaymentType({
    required this.id,
    required this.typeName,
    this.description,
  });

  factory PaymentType.fromJson(Map<String, dynamic> json) {
    return PaymentType(
      id: JsonParsers.toInt(json['id']),
      typeName: JsonParsers.toStringValue(json['typeName']),
      description: JsonParsers.toNullableString(json['description']),
    );
  }
}