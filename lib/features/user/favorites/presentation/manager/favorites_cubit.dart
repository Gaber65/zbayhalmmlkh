import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dhabayih_lmamlaka/features/user/catalog/domain/entities/product.dart';
import '../../domain/entities/favorite_product.dart';
import '../../domain/repositories/favorites_repository.dart';
import 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  final FavoritesRepository repository;

  FavoritesCubit({required this.repository}) : super(FavoritesInitial());

  List<FavoriteProduct> _currentFavorites = [];
  Set<int> _currentFavoriteIds = {};

  bool isFavorite(int productId) {
    return _currentFavoriteIds.contains(productId);
  }

  Future<void> loadFavorites() async {
    emit(FavoritesLoading());
    final result = await repository.getFavorites();
    result.fold(
      (failure) {
        emit(FavoritesError(message: failure.error.message));
      },
      (items) {
        _currentFavorites = List.from(items);
        _currentFavoriteIds = items.map((e) => e.id).toSet();
        emit(FavoritesLoaded(
          favorites: _currentFavorites,
          favoriteIds: _currentFavoriteIds,
        ));
      },
    );
  }

  Future<void> toggleFavorite({
    required dynamic product,
    String? title,
    double? price,
    String? imageUrl,
    String? subtitle,
  }) async {
    int? productId;
    FavoriteProduct? favItem;

    if (product is Product) {
      productId = product.id;
      favItem = FavoriteProduct.fromProduct(product);
    } else if (product is FavoriteProduct) {
      productId = product.id;
      favItem = product;
    } else if (product is int) {
      productId = product;
      favItem = FavoriteProduct(
        id: productId,
        title: title ?? '',
        subtitle: subtitle ?? '',
        price: price ?? 0.0,
        imageUrl: imageUrl ?? '',
      );
    } else if (product is Map) {
      productId = (product['id'] as num?)?.toInt();
      favItem = FavoriteProduct.fromMap(Map<String, dynamic>.from(product));
    }

    if (productId == null || favItem == null) return;

    final currentlyFav = _currentFavoriteIds.contains(productId);

    if (currentlyFav) {
      // Remove
      _currentFavoriteIds.remove(productId);
      _currentFavorites.removeWhere((e) => e.id == productId);
      emit(FavoritesLoaded(
        favorites: List.from(_currentFavorites),
        favoriteIds: Set.from(_currentFavoriteIds),
        feedbackMessage: 'تمت إزالة المنتج من المفضلة',
      ));
      await repository.removeFavorite(productId);
    } else {
      // Add
      _currentFavoriteIds.add(productId);
      _currentFavorites.insert(0, favItem);
      emit(FavoritesLoaded(
        favorites: List.from(_currentFavorites),
        favoriteIds: Set.from(_currentFavoriteIds),
        feedbackMessage: 'تمت إضافة المنتج إلى المفضلة',
      ));
      await repository.addFavorite(favItem);
    }
  }

  Future<void> removeFavorite(int productId) async {
    if (!_currentFavoriteIds.contains(productId)) return;
    _currentFavoriteIds.remove(productId);
    _currentFavorites.removeWhere((e) => e.id == productId);
    emit(FavoritesLoaded(
      favorites: List.from(_currentFavorites),
      favoriteIds: Set.from(_currentFavoriteIds),
      feedbackMessage: 'تمت إزالة المنتج من المفضلة',
    ));
    await repository.removeFavorite(productId);
  }
}
