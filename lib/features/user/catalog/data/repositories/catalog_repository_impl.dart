import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:dhabayih_lmamlaka/core/error/exceptions.dart';
import 'package:dhabayih_lmamlaka/core/error/failure.dart';
import 'package:dhabayih_lmamlaka/core/network/error_message_model.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../datasources/catalog_remote_data_source.dart';

@LazySingleton(as: CatalogRepository)
class CatalogRepositoryImpl implements CatalogRepository {
  final CatalogRemoteDataSource remoteDataSource;

  CatalogRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Category>>> getCategories() async {
    try {
      final categories = await remoteDataSource.getCategories();
      return Right(categories.map((c) => c.toDomain()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorMessageModel));
    } catch (e) {
      return Left(ServerFailure(ErrorMessageModel(message: e.toString(), errors: [], success: false, statusCode: 500)));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getProducts() async {
    try {
      final products = await remoteDataSource.getProducts();
      return Right(products.map((p) => p.toDomain()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorMessageModel));
    } catch (e) {
      return Left(ServerFailure(ErrorMessageModel(message: e.toString(), errors: [], success: false, statusCode: 500)));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getBestSellers() async {
    // Usually a separate API call or filtered from products
    try {
      final products = await remoteDataSource.getProducts();
      // Filter logic here or dedicated endpoint
      return Right(products.where((p) => p.isBestSeller).map((p) => p.toDomain()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorMessageModel));
    } catch (e) {
      return Left(ServerFailure(ErrorMessageModel(message: e.toString(), errors: [], success: false, statusCode: 500)));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getOffers() async {
    try {
      final products = await remoteDataSource.getProducts();
      // Filter logic here or dedicated endpoint
      return Right(products.where((p) => p.isOffer || p.originalPrice != null).map((p) => p.toDomain()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorMessageModel));
    } catch (e) {
      return Left(ServerFailure(ErrorMessageModel(message: e.toString(), errors: [], success: false, statusCode: 500)));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getProductsByCategory(int categoryId) async {
    try {
      final products = await remoteDataSource.getProductsByCategory(categoryId);
      return Right(products.map((p) => p.toDomain()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorMessageModel));
    } catch (e) {
      return Left(ServerFailure(ErrorMessageModel(message: e.toString(), errors: [], success: false, statusCode: 500)));
    }
  }

  @override
  Future<Either<Failure, Product>> getProductById(int productId) async {
    try {
      final product = await remoteDataSource.getProductById(productId);
      return Right(product.toDomain());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorMessageModel));
    } catch (e) {
      return Left(ServerFailure(ErrorMessageModel(message: e.toString(), errors: [], success: false, statusCode: 500)));
    }
  }
}
