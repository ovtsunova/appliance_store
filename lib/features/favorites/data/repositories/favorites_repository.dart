import 'package:dio/dio.dart';

import '../../domain/models/favorite_item.dart';

class FavoritesRepository {
  final Dio dio;

  const FavoritesRepository(this.dio);

  Future<List<FavoriteItem>> getFavorites() async {
    final response = await dio.get('/favorites');
    final data = response.data as List<dynamic>;

    return data
        .map((item) => FavoriteItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> addFavorite(int productId) async {
    await dio.post('/favorites/$productId');
  }

  Future<void> removeFavorite(int productId) async {
    await dio.delete('/favorites/$productId');
  }
}