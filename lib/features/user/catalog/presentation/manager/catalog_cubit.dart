import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/catalog_repository.dart';
import 'catalog_state.dart';

@injectable
class CatalogCubit extends Cubit<CatalogState> {
  final CatalogRepository repository;

  CatalogCubit({required this.repository}) : super(CatalogInitial());

  Future<void> fetchCatalog() async {
    emit(CatalogLoading());

    final categoriesResult = await repository.getCategories();
    final productsResult = await repository.getProducts();
    final offersResult = await repository.getOffers();
    final bestSellersResult = await repository.getBestSellers();

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
