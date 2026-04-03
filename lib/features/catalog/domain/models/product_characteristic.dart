import '../../../../core/utils/json_parsers.dart';

class ProductCharacteristic {
  final String name;
  final String value;

  const ProductCharacteristic({
    required this.name,
    required this.value,
  });

  factory ProductCharacteristic.fromJson(Map<String, dynamic> json) {
    return ProductCharacteristic(
      name: JsonParsers.toStringValue(json['name']),
      value: JsonParsers.toStringValue(json['value']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
    };
  }
}