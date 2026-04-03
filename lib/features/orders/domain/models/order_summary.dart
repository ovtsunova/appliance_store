import '../../../../core/utils/json_parsers.dart';

class OrderSummary {
  final int id;
  final String? orderDate;
  final double totalAmount;
  final String? orderComment;
  final String status;
  final String deliveryType;
  final String paymentType;

  const OrderSummary({
    required this.id,
    this.orderDate,
    required this.totalAmount,
    this.orderComment,
    required this.status,
    required this.deliveryType,
    required this.paymentType,
  });

  factory OrderSummary.fromJson(Map<String, dynamic> json) {
    return OrderSummary(
      id: JsonParsers.toInt(json['id']),
      orderDate: JsonParsers.toNullableString(json['orderDate']),
      totalAmount: JsonParsers.toDouble(json['totalAmount']),
      orderComment: JsonParsers.toNullableString(json['orderComment']),
      status: JsonParsers.toStringValue(json['status']),
      deliveryType: JsonParsers.toStringValue(json['deliveryType']),
      paymentType: JsonParsers.toStringValue(json['paymentType']),
    );
  }

  bool get canBeCancelled => status == 'Новый';
}