import 'package:dartz/dartz.dart';
import 'package:dhabayih_lmamlaka/core/error/failure.dart';
import '../entities/category.dart';
import '../entities/product.dart';

abstract class CatalogRepository {
  Future<Either<Failure, List<Category>>> getCategories();
  Future<Either<Failure, List<Product>>> getProducts();
  Future<Either<Failure, List<Product>>> getOffers();
  Future<Either<Failure, List<Product>>> getBestSellers();
  Future<Either<Failure, List<Product>>> getProductsByCategory(int categoryId);
  Future<Either<Failure, Product>> getProductById(int productId);
}
