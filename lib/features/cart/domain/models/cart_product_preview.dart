import '../../../../core/utils/json_parsers.dart';

class CartProductPreview {
  final int id;
  final String name;
  final String model;
  final String? description;
  final double price;
  final int stockQuantity;
  final String? imageUrl;
  final String? warrantyPeriod;
  final String brandName;
  final String categoryName;

  const CartProductPreview({
    required this.id,
    required this.name,
    required this.model,
    this.description,
    required this.price,
    required this.stockQuantity,
    this.imageUrl,
    this.warrantyPeriod,
    required this.brandName,
    required this.categoryName,
  });

  factory CartProductPreview.fromJson(Map<String, dynamic> json) {
    final brand = (json['brand'] as Map<String, dynamic>? ?? {});
    final category = (json['category'] as Map<String, dynamic>? ?? {});

    return CartProductPreview(
      id: JsonParsers.toInt(json['id']),
      name: JsonParsers.toStringValue(json['name']),
      model: JsonParsers.toStringValue(json['model']),
      description: JsonParsers.toNullableString(json['description']),
      price: JsonParsers.toDouble(json['price']),
      stockQuantity: JsonParsers.toInt(json['stockQuantity']),
      imageUrl: JsonParsers.toNullableString(json['imageUrl']),
      warrantyPeriod: JsonParsers.toNullableString(json['warrantyPeriod']),
      brandName: JsonParsers.toStringValue(brand['name']),
      categoryName: JsonParsers.toStringValue(category['name']),
    );
  }
}