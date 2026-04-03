import '../../../../core/utils/json_parsers.dart';
import 'cart_product_preview.dart';

class CartItem {
  final int cartItemId;
  final int quantity;
  final String? addedDate;
  final double itemTotal;
  final CartProductPreview product;

  const CartItem({
    required this.cartItemId,
    required this.quantity,
    this.addedDate,
    required this.itemTotal,
    required this.product,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      cartItemId: JsonParsers.toInt(json['cartItemId']),
      quantity: JsonParsers.toInt(json['quantity']),
      addedDate: JsonParsers.toNullableString(json['addedDate']),
      itemTotal: JsonParsers.toDouble(json['itemTotal']),
      product: CartProductPreview.fromJson(
        json['product'] as Map<String, dynamic>,
      ),
    );
  }
}