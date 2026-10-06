import 'package:equatable/equatable.dart';
import '../../domain/entities/favorite_product.dart';

abstract class FavoritesState extends Equatable {
  const FavoritesState();

  @override
  List<Object?> get props => [];
}

class FavoritesInitial extends FavoritesState {}

class FavoritesLoading extends FavoritesState {}

class FavoritesLoaded extends FavoritesState {
  final List<FavoriteProduct> favorites;
  final Set<int> favoriteIds;
  final String? feedbackMessage;

  const FavoritesLoaded({
    required this.favorites,
    required this.favoriteIds,
    this.feedbackMessage,
  });

  @override
  List<Object?> get props => [favorites, favoriteIds, feedbackMessage];

  FavoritesLoaded copyWith({
    List<FavoriteProduct>? favorites,
    Set<int>? favoriteIds,
    String? feedbackMessage,
  }) {
    return FavoritesLoaded(
      favorites: favorites ?? this.favorites,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      feedbackMessage: feedbackMessage,
    );
  }
}

class FavoritesError extends FavoritesState {
  final String message;

  const FavoritesError({required this.message});

  @override
  List<Object?> get props => [message];
}
