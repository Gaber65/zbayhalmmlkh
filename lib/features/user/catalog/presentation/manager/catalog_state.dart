import 'package:equatable/equatable.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';

abstract class CatalogState extends Equatable {
  const CatalogState();

  @override
  List<Object?> get props => [];
}

class CatalogInitial extends CatalogState {}

class CatalogLoading extends CatalogState {}

class CatalogLoaded extends CatalogState {
  final List<Category> categories;
  final List<Product> products;
  final List<Product> offers;
  final List<Product> bestSellers;

  const CatalogLoaded({
    required this.categories,
    required this.products,
    required this.offers,
    required this.bestSellers,
  });

  @override
  List<Object?> get props => [categories, products, offers, bestSellers];
}

class CatalogError extends CatalogState {
  final String message;

  const CatalogError(this.message);

  @override
  List<Object?> get props => [message];
}

class CategoriesLoaded extends CatalogState {
  final List<Category> categories;

  const CategoriesLoaded({required this.categories});

  @override
  List<Object?> get props => [categories];
}

class ProductsByCategoryLoading extends CatalogState {}

class ProductsByCategoryLoaded extends CatalogState {
  final List<Product> products;

  const ProductsByCategoryLoaded({required this.products});

  @override
  List<Object?> get props => [products];
}

class ProductDetailLoading extends CatalogState {}

class ProductDetailLoaded extends CatalogState {
  final Product product;

  const ProductDetailLoaded({required this.product});

  @override
  List<Object?> get props => [product];
}

class ProductDetailError extends CatalogState {
  final String message;

  const ProductDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
