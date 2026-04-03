import '../../../../core/utils/json_parsers.dart';
import '../../../catalog/domain/models/product.dart';

class FavoriteItem {
  final int favoriteId;
  final String? addedDate;
  final Product product;

  const FavoriteItem({
    required this.favoriteId,
    this.addedDate,
    required this.product,
  });

  factory FavoriteItem.fromJson(Map<String, dynamic> json) {
    return FavoriteItem(
      favoriteId: JsonParsers.toInt(json['favoriteId']),
      addedDate: JsonParsers.toNullableString(json['addedDate']),
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
    );
  }
}