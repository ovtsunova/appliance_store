import '../../../../core/utils/json_parsers.dart';
import 'brand.dart';
import 'category.dart';
import 'product_characteristic.dart';

class Product {
  final int id;
  final String name;
  final String model;
  final String? description;
  final double price;
  final int stockQuantity;
  final String? imageUrl;
  final String? warrantyPeriod;
  final double? averageRating;
  final Brand brand;
  final Category category;
  final List<ProductCharacteristic> characteristics;

  const Product({
    required this.id,
    required this.name,
    required this.model,
    this.description,
    required this.price,
    required this.stockQuantity,
    this.imageUrl,
    this.warrantyPeriod,
    this.averageRating,
    required this.brand,
    required this.category,
    required this.characteristics,
  });

  bool get inStock => stockQuantity > 0;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: JsonParsers.toInt(json['id']),
      name: JsonParsers.toStringValue(json['name']),
      model: JsonParsers.toStringValue(json['model']),
      description: JsonParsers.toNullableString(json['description']),
      price: JsonParsers.toDouble(json['price']),
      stockQuantity: JsonParsers.toInt(json['stockQuantity']),
      imageUrl: JsonParsers.toNullableString(json['imageUrl']),
      warrantyPeriod: JsonParsers.toNullableString(json['warrantyPeriod']),
      averageRating: json['averageRating'] == null
          ? null
          : JsonParsers.toDouble(json['averageRating']),
      brand: Brand.fromJson(json['brand'] as Map<String, dynamic>),
      category: Category.fromJson(json['category'] as Map<String, dynamic>),
      characteristics: (json['characteristics'] as List<dynamic>? ?? [])
          .map(
            (item) => ProductCharacteristic.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }
}