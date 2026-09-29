import 'package:dartz/dartz.dart';
import 'package:dhabayih_lmamlaka/core/error/failure.dart';
import '../../../catalog/domain/entities/product.dart';

abstract class SearchRepository {
  Future<Either<Failure, List<Product>>> searchProducts(String query);
  Future<Either<Failure, List<String>>> getPopularSearches();
}
