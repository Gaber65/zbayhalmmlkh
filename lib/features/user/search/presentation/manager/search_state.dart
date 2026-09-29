import 'package:equatable/equatable.dart';
import '../../../catalog/domain/entities/product.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {
  final List<String> popularSearches;
  final List<String> recentSearches;

  const SearchInitial({
    this.popularSearches = const [],
    this.recentSearches = const [],
  });

  @override
  List<Object?> get props => [popularSearches, recentSearches];
}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<Product> results;
  final String query;

  const SearchLoaded({required this.results, required this.query});

  @override
  List<Object?> get props => [results, query];
}

class SearchError extends SearchState {
  final String message;

  const SearchError(this.message);

  @override
  List<Object?> get props => [message];
}
