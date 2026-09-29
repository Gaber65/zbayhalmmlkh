import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:dhabayih_lmamlaka/core/error/failure.dart';
import '../../../catalog/domain/entities/product.dart';
import '../repositories/search_repository.dart';

@lazySingleton
class SearchProductsUseCase {
  final SearchRepository repository;
  SearchProductsUseCase(this.repository);

  Future<Either<Failure, List<Product>>> call(String query) {
    return repository.searchProducts(query);
  }
}

@lazySingleton
class GetPopularSearchesUseCase {
  final SearchRepository repository;
  GetPopularSearchesUseCase(this.repository);

  Future<Either<Failure, List<String>>> call() {
    return repository.getPopularSearches();
  }
}
