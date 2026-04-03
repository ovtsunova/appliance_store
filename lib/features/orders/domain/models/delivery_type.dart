import '../../../../core/utils/json_parsers.dart';

class DeliveryType {
  final int id;
  final String typeName;
  final double cost;
  final String estimatedDeliveryTime;

  const DeliveryType({
    required this.id,
    required this.typeName,
    required this.cost,
    required this.estimatedDeliveryTime,
  });

  factory DeliveryType.fromJson(Map<String, dynamic> json) {
    return DeliveryType(
      id: JsonParsers.toInt(json['id']),
      typeName: JsonParsers.toStringValue(json['typeName']),
      cost: JsonParsers.toDouble(json['cost']),
      estimatedDeliveryTime:
          JsonParsers.toStringValue(json['estimatedDeliveryTime']),
    );
  }
}