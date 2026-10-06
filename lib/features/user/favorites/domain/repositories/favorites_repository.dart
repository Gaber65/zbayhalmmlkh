import 'package:dartz/dartz.dart';
import 'package:dhabayih_lmamlaka/core/error/failure.dart';
import '../entities/favorite_product.dart';

abstract class FavoritesRepository {
  Future<Either<Failure, List<FavoriteProduct>>> getFavorites();
  Future<Either<Failure, bool>> addFavorite(FavoriteProduct item);
  Future<Either<Failure, bool>> removeFavorite(int productId);
  Future<bool> isFavorite(int productId);
}
