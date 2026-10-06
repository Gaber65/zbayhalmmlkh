import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/favorite_product.dart';

abstract class FavoritesLocalDataSource {
  Future<List<FavoriteProduct>> getFavorites();
  Future<void> saveFavorites(List<FavoriteProduct> favorites);
  Future<void> addFavorite(FavoriteProduct item);
  Future<void> removeFavorite(int productId);
  Future<bool> isFavorite(int productId);
  Future<void> clearFavorites();
}

class FavoritesLocalDataSourceImpl implements FavoritesLocalDataSource {
  static const String _key = 'user_favorites_data_v1';
  final SharedPreferences sharedPreferences;

  FavoritesLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<FavoriteProduct>> getFavorites() async {
    try {
      final jsonString = sharedPreferences.getString(_key);
      if (jsonString == null || jsonString.isEmpty) return [];
      final List decoded = json.decode(jsonString);
      return decoded.map((e) => FavoriteProduct.fromMap(Map<String, dynamic>.from(e))).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> saveFavorites(List<FavoriteProduct> favorites) async {
    final list = favorites.map((e) => e.toMap()).toList();
    await sharedPreferences.setString(_key, json.encode(list));
  }

  @override
  Future<void> addFavorite(FavoriteProduct item) async {
    final current = await getFavorites();
    if (!current.any((e) => e.id == item.id)) {
      current.insert(0, item);
      await saveFavorites(current);
    }
  }

  @override
  Future<void> removeFavorite(int productId) async {
    final current = await getFavorites();
    current.removeWhere((e) => e.id == productId);
    await saveFavorites(current);
  }

  @override
  Future<bool> isFavorite(int productId) async {
    final current = await getFavorites();
    return current.any((e) => e.id == productId);
  }

  @override
  Future<void> clearFavorites() async {
    await sharedPreferences.remove(_key);
  }
}
