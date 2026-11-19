import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:dhabayih_lmamlaka/core/error/failure.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/catalog_repository.dart';
import 'catalog_state.dart';

@injectable
class CatalogCubit extends Cubit<CatalogState> {
  final CatalogRepository repository;

  CatalogCubit({required this.repository}) : super(CatalogInitial());

  Future<void> fetchCatalog() async {
    if (!isClosed) emit(CatalogLoading());

    // Parallelize network requests to eliminate waterfall latency
    final results = await Future.wait([
      repository.getCategories(),
      repository.getProducts(),
      repository.getOffers(),
      repository.getBestSellers(),
    ]);

    final categoriesResult = results[0] as Either<Failure, List<Category>>;
    final productsResult = results[1] as Either<Failure, List<Product>>;
    final offersResult = results[2] as Either<Failure, List<Product>>;
    final bestSellersResult = results[3] as Either<Failure, List<Product>>;

    String? errorMsg;
    final categories = categoriesResult.fold<List<Category>>(
      (failure) {
        errorMsg ??= failure.error.message;
        return const [];
      },
      (list) => list,
    );
    final products = productsResult.fold<List<Product>>(
      (failure) {
        errorMsg ??= failure.error.message;
        return const [];
      },
      (list) => list,
    );
    final offers = offersResult.fold<List<Product>>(
      (_) => const [],
      (list) => list,
    );
    final bestSellers = bestSellersResult.fold<List<Product>>(
      (_) => const [],
      (list) => list,
    );

    if (categories.isEmpty && products.isEmpty && errorMsg != null) {
      emit(CatalogError(errorMsg!));
      return;
    }

    emit(CatalogLoaded(
      categories: categories,
      products: products,
      offers: offers,
      bestSellers: bestSellers,
    ));
  }

  Future<void> fetchProductsByCategory(int categoryId) async {
    emit(ProductsByCategoryLoading());

    final result = await repository.getProductsByCategory(categoryId);

    result.fold(
      (failure) => emit(CatalogError(failure.error.message)),
      (products) => emit(ProductsByCategoryLoaded(products: products)),
    );
  }

  Future<void> fetchCategories() async {
    emit(CatalogLoading());

    final result = await repository.getCategories();

    result.fold(
      (failure) => emit(CatalogError(failure.error.message)),
      (categories) => emit(CategoriesLoaded(categories: categories)),
    );
  }

  Future<void> fetchProductById(int productId) async {
    emit(ProductDetailLoading());

    final result = await repository.getProductById(productId);

    result.fold(
      (failure) => emit(ProductDetailError(failure.error.message)),
      (product) => emit(ProductDetailLoaded(product: product)),
    );
  }
}
