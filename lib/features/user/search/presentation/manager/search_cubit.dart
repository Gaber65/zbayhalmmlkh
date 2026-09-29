import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import '../../domain/usecases/search_usecases.dart';
import '../manager/search_state.dart';

@injectable
class SearchCubit extends Cubit<SearchState> {
  final SearchProductsUseCase _searchProductsUseCase;
  final GetPopularSearchesUseCase _getPopularSearchesUseCase;
  
  List<String> _popularSearchesCache = [];
  final List<String> _recentSearches = []; // In a real app, load from local storage

  final _searchSubject = PublishSubject<String>();
  StreamSubscription? _searchSubscription;

  SearchCubit(
    this._searchProductsUseCase,
    this._getPopularSearchesUseCase,
  ) : super(const SearchInitial()) {
    _searchSubscription = _searchSubject
        .debounceTime(const Duration(milliseconds: 500))
        .listen((query) {
      _performSearch(query);
    });
  }

  @override
  Future<void> close() {
    _searchSubscription?.cancel();
    _searchSubject.close();
    return super.close();
  }

  Future<void> loadInitial() async {
    final popularResult = await _getPopularSearchesUseCase();
    popularResult.fold(
      (failure) => emit(const SearchError('Failed to load popular searches')),
      (popular) {
        _popularSearchesCache = popular;
        emit(SearchInitial(
          popularSearches: _popularSearchesCache,
          recentSearches: _recentSearches,
        ));
      },
    );
  }

  void searchQueryChanged(String query) {
    _searchSubject.add(query);
  }

  Future<void> _performSearch(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      emit(SearchInitial(
        popularSearches: _popularSearchesCache,
        recentSearches: _recentSearches,
      ));
      return;
    }

    emit(SearchLoading());
    final result = await _searchProductsUseCase(trimmedQuery);
    result.fold(
      (failure) => emit(SearchError(failure.error.message)),
      (results) {
        if (!_recentSearches.contains(trimmedQuery)) {
          _recentSearches.insert(0, trimmedQuery);
          if (_recentSearches.length > 5) {
            _recentSearches.removeLast();
          }
        }
        emit(SearchLoaded(results: results, query: trimmedQuery));
      },
    );
  }

  void clearSearch() {
    emit(SearchInitial(
      popularSearches: _popularSearchesCache,
      recentSearches: _recentSearches,
    ));
  }
}
