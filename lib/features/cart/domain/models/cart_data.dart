import '../../../../core/utils/json_parsers.dart';
import 'cart_item.dart';

class CartData {
  final List<CartItem> items;
  final double totalAmount;

  const CartData({
    required this.items,
    required this.totalAmount,
  });

  factory CartData.fromJson(Map<String, dynamic> json) {
    return CartData(
      items: (json['items'] as List<dynamic>? ?? [])
          .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalAmount: JsonParsers.toDouble(json['totalAmount']),
    );
  }
}