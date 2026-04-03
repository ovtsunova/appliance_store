import '../../../../core/utils/json_parsers.dart';

class Category {
  final int id;
  final String name;
  final String? description;
  final int? parentCategoryId;

  const Category({
    required this.id,
    required this.name,
    this.description,
    this.parentCategoryId,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: JsonParsers.toInt(json['id']),
      name: JsonParsers.toStringValue(json['name']),
      description: JsonParsers.toNullableString(json['description']),
      parentCategoryId: json['parentCategoryId'] == null
          ? null
          : JsonParsers.toInt(json['parentCategoryId']),
    );
  }
}