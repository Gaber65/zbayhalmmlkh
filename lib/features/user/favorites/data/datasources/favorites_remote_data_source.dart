import 'package:dio/dio.dart';
import 'package:dhabayih_lmamlaka/core/api/server_strings.dart';
import '../../domain/entities/favorite_product.dart';

abstract class FavoritesRemoteDataSource {
  Future<List<FavoriteProduct>> getFavorites();
  Future<bool> addFavorite(int productId);
  Future<bool> removeFavorite(int productId);
}

class FavoritesRemoteDataSourceImpl implements FavoritesRemoteDataSource {
  final Dio dio;

  FavoritesRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<FavoriteProduct>> getFavorites() async {
    final response = await dio.get(ServerStrings.favorites);
    if (response.statusCode == 200 && response.data != null) {
      final data = response.data['data'];
      if (data is List) {
        return data.map((e) => FavoriteProduct.fromMap(Map<String, dynamic>.from(e))).toList();
      }
    }
    return [];
  }

  @override
  Future<bool> addFavorite(int productId) async {
    final response = await dio.post(
      ServerStrings.favorites,
      data: {'product_id': productId},
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  @override
  Future<bool> removeFavorite(int productId) async {
    final response = await dio.delete(ServerStrings.removeFavorite(productId));
    return response.statusCode == 200;
  }
}
