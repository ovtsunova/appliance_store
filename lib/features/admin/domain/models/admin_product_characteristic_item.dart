import '../../../../core/utils/json_parsers.dart';

class AdminProductCharacteristicItem {
  final int id;
  final String name;
  final String value;

  const AdminProductCharacteristicItem({
    required this.id,
    required this.name,
    required this.value,
  });

  factory AdminProductCharacteristicItem.fromJson(Map<String, dynamic> json) {
    return AdminProductCharacteristicItem(
      id: JsonParsers.toInt(json['id']),
      name: JsonParsers.toStringValue(json['name']),
      value: JsonParsers.toStringValue(json['value']),
    );
  }
}