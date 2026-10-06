import 'package:dartz/dartz.dart';
import 'package:dhabayih_lmamlaka/core/error/failure.dart';
import 'package:dhabayih_lmamlaka/core/network/error_message_model.dart';
import '../../domain/entities/favorite_product.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../datasources/favorites_local_data_source.dart';
import '../datasources/favorites_remote_data_source.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesLocalDataSource localDataSource;
  final FavoritesRemoteDataSource remoteDataSource;

  FavoritesRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, List<FavoriteProduct>>> getFavorites() async {
    try {
      // 1. Try fetching from remote if online
      try {
        final remoteItems = await remoteDataSource.getFavorites();
        if (remoteItems.isNotEmpty) {
          await localDataSource.saveFavorites(remoteItems);
          return Right(remoteItems);
        }
      } catch (_) {
        // Fallback to local
      }

      // 2. Return local cached items
      final localItems = await localDataSource.getFavorites();
      return Right(localItems);
    } catch (e) {
      return Left(ServerFailure(ErrorMessageModel(
        errors: [],
        message: e.toString(),
        success: false,
        statusCode: 500,
      )));
    }
  }

  @override
  Future<Either<Failure, bool>> addFavorite(FavoriteProduct item) async {
    try {
      await localDataSource.addFavorite(item);
      try {
        await remoteDataSource.addFavorite(item.id);
      } catch (_) {
        // Local is saved
      }
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure(ErrorMessageModel(
        errors: [],
        message: e.toString(),
        success: false,
        statusCode: 500,
      )));
    }
  }

  @override
  Future<Either<Failure, bool>> removeFavorite(int productId) async {
    try {
      await localDataSource.removeFavorite(productId);
      try {
        await remoteDataSource.removeFavorite(productId);
      } catch (_) {
        // Local is removed
      }
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure(ErrorMessageModel(
        errors: [],
        message: e.toString(),
        success: false,
        statusCode: 500,
      )));
    }
  }

  @override
  Future<bool> isFavorite(int productId) async {
    return await localDataSource.isFavorite(productId);
  }
}
