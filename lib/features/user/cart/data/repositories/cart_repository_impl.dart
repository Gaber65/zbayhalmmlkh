import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:dhabayih_lmamlaka/core/error/exceptions.dart';
import 'package:dhabayih_lmamlaka/core/error/failure.dart';
import 'package:dhabayih_lmamlaka/core/network/error_message_model.dart';
import '../../domain/entities/cart.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_remote_data_source.dart';

@LazySingleton(as: CartRepository)
class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource remoteDataSource;
  CartRepositoryImpl({required this.remoteDataSource});

  Either<Failure, CartEntity> _handleError(Object e) {
    if (e is ServerException) {
      return Left(ServerFailure(e.errorMessageModel));
    }
    return Left(ServerFailure(ErrorMessageModel(
      message: e.toString(),
      errors: [],
      success: false,
      statusCode: 500,
    )));
  }

  @override
  Future<Either<Failure, CartEntity>> getCart() async {
    try {
      final model = await remoteDataSource.getCart();
      return Right(model.toDomain());
    } catch (e) {
      return _handleError(e);
    }
  }

  @override
  Future<Either<Failure, CartEntity>> addToCart({
    required int productId,
    required double quantity,
    int? cuttingOptionId,
    List<int>? packagingIds,
    List<int>? excludedPartIds,
    String? notes,
    int? sizeId,
  }) async {
    try {
      final model = await remoteDataSource.addToCart(
        productId: productId,
        quantity: quantity,
        cuttingOptionId: cuttingOptionId,
        packagingIds: packagingIds,
        excludedPartIds: excludedPartIds,
        notes: notes,
        sizeId: sizeId,
      );
      return Right(model.toDomain());
    } catch (e) {
      return _handleError(e);
    }
  }

  @override
  Future<Either<Failure, CartEntity>> updateCartItem({
    required int productId,
    required double quantity,
    int? cuttingOptionId,
    List<int>? packagingIds,
    List<int>? excludedPartIds,
    String? notes,
  }) async {
    try {
      final model = await remoteDataSource.updateCartItem(
        productId: productId,
        quantity: quantity,
        cuttingOptionId: cuttingOptionId,
        packagingIds: packagingIds,
        excludedPartIds: excludedPartIds,
        notes: notes,
      );
      return Right(model.toDomain());
    } catch (e) {
      return _handleError(e);
    }
  }

  @override
  Future<Either<Failure, CartEntity>> removeFromCart({required int productId}) async {
    try {
      final model = await remoteDataSource.removeFromCart(productId: productId);
      return Right(model.toDomain());
    } catch (e) {
      return _handleError(e);
    }
  }

  @override
  Future<Either<Failure, CartEntity>> clearCart() async {
    try {
      final model = await remoteDataSource.clearCart();
      return Right(model.toDomain());
    } catch (e) {
      return _handleError(e);
    }
  }
}
