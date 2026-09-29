import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../user/catalog/domain/entities/product.dart';
import '../../domain/repositories/admin_repository.dart';

abstract class AdminProductsState extends Equatable {
  const AdminProductsState();
  @override
  List<Object?> get props => [];
}

class AdminProductsInitial extends AdminProductsState {}

class AdminProductsLoading extends AdminProductsState {}

class AdminProductsLoaded extends AdminProductsState {
  final List<Product> allProducts;
  final String searchQuery;
  final int? selectedCategoryId;
  final String activeFilter; // 'all' | 'on_offer' | 'low_stock' | 'featured' | 'best_seller' | 'active' | 'inactive'
  final bool isSubmitting;
  final bool hasReachedMax;
  final bool isLoadingMore;

  const AdminProductsLoaded({
    required this.allProducts,
    this.searchQuery = '',
    this.selectedCategoryId,
    this.activeFilter = 'all',
    this.isSubmitting = false,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
  });

  /// Computed list of products filtered by current query, category, and quick filter tab
  List<Product> get products {
    return allProducts.where((p) {
      // 1. Search query filter
      if (searchQuery.trim().isNotEmpty) {
        final q = searchQuery.trim().toLowerCase();
        final matchTitle = p.title.toLowerCase().contains(q) || (p.titleAr != null && p.titleAr!.toLowerCase().contains(q));
        final matchSku = p.sku != null && p.sku!.toLowerCase().contains(q);
        final matchBarcode = p.barcode != null && p.barcode!.toLowerCase().contains(q);
        if (!matchTitle && !matchSku && !matchBarcode) return false;
      }

      // 2. Category filter
      if (selectedCategoryId != null && selectedCategoryId! > 0) {
        if (p.categoryId != selectedCategoryId) return false;
      }

      // 3. Quick ERP Filter
      switch (activeFilter) {
        case 'on_offer':
          return p.isOnOffer;
        case 'low_stock':
          return p.isLowStock;
        case 'featured':
          return p.isFeatured;
        case 'best_seller':
          return p.isBestSeller;
        case 'active':
          return p.active;
        case 'inactive':
          return !p.active;
        case 'all':
        default:
          return true;
      }
    }).toList();
  }

  AdminProductsLoaded copyWith({
    List<Product>? allProducts,
    String? searchQuery,
    int? selectedCategoryId,
    bool clearCategoryId = false,
    String? activeFilter,
    bool? isSubmitting,
    bool? hasReachedMax,
    bool? isLoadingMore,
  }) {
    return AdminProductsLoaded(
      allProducts: allProducts ?? this.allProducts,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategoryId: clearCategoryId ? null : (selectedCategoryId ?? this.selectedCategoryId),
      activeFilter: activeFilter ?? this.activeFilter,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [
        allProducts,
        searchQuery,
        selectedCategoryId,
        activeFilter,
        isSubmitting,
        hasReachedMax,
        isLoadingMore,
      ];
}

class AdminProductsError extends AdminProductsState {
  final String message;
  const AdminProductsError({required this.message});
  @override
  List<Object?> get props => [message];
}

@injectable
class AdminProductsCubit extends Cubit<AdminProductsState> {
  final AdminRepository repository;

  AdminProductsCubit({required this.repository}) : super(AdminProductsInitial());

  String _searchQuery = '';
  int? _categoryId;
  String _activeFilter = 'all';

  Future<void> loadProducts({
    String? query,
    int? categoryId,
    String? filter,
    bool silent = false,
  }) async {
    if (query != null) _searchQuery = query;
    if (categoryId != null) _categoryId = categoryId;
    if (filter != null) _activeFilter = filter;

    if (!silent) {
      emit(AdminProductsLoading());
    }

    final result = await repository.getAdminProducts(
      query: _searchQuery,
      categoryId: _categoryId,
      filter: _activeFilter,
      limit: 20,
      offset: 0,
    );

    result.fold(
      (failure) => emit(AdminProductsError(message: failure.error.message)),
      (products) {
        emit(AdminProductsLoaded(
          allProducts: products,
          searchQuery: _searchQuery,
          selectedCategoryId: _categoryId,
          activeFilter: _activeFilter,
          hasReachedMax: products.length < 20,
          isLoadingMore: false,
        ));
      },
    );
  }

  Future<void> loadMoreProducts() async {
    if (state is! AdminProductsLoaded) return;
    final current = state as AdminProductsLoaded;
    if (current.hasReachedMax || current.isLoadingMore) return;

    emit(current.copyWith(isLoadingMore: true));

    final result = await repository.getAdminProducts(
      query: _searchQuery,
      categoryId: _categoryId,
      filter: _activeFilter,
      limit: 20,
      offset: current.allProducts.length,
    );

    result.fold(
      (failure) => emit(current.copyWith(isLoadingMore: false)),
      (newProducts) {
        if (newProducts.isEmpty) {
          emit(current.copyWith(
            isLoadingMore: false,
            hasReachedMax: true,
          ));
        } else {
          final existingIds = current.allProducts.map((p) => p.id).toSet();
          final uniqueNew = newProducts.where((p) => !existingIds.contains(p.id)).toList();
          emit(current.copyWith(
            allProducts: [...current.allProducts, ...uniqueNew],
            isLoadingMore: false,
            hasReachedMax: newProducts.length < 20,
          ));
        }
      },
    );
  }

  void search(String query) {
    _searchQuery = query;
    if (state is AdminProductsLoaded) {
      final current = state as AdminProductsLoaded;
      emit(current.copyWith(searchQuery: query));
    }
    loadProducts(query: query, silent: true);
  }

  void setFilter(String filter) {
    _activeFilter = filter;
    if (state is AdminProductsLoaded) {
      final current = state as AdminProductsLoaded;
      emit(current.copyWith(activeFilter: filter));
    }
    loadProducts(filter: filter, silent: true);
  }

  void setCategoryFilter(int? catId) {
    _categoryId = catId;
    if (state is AdminProductsLoaded) {
      final current = state as AdminProductsLoaded;
      emit(current.copyWith(selectedCategoryId: catId, clearCategoryId: catId == null));
    }
    loadProducts(categoryId: catId, silent: true);
  }

  Future<bool> createProduct(Map<String, dynamic> data) async {
    if (state is AdminProductsLoaded) {
      final current = state as AdminProductsLoaded;
      emit(current.copyWith(isSubmitting: true));
    }

    final result = await repository.createProduct(data);
    return result.fold(
      (failure) {
        if (state is AdminProductsLoaded) {
          final current = state as AdminProductsLoaded;
          emit(current.copyWith(isSubmitting: false));
        }
        return false;
      },
      (newProduct) {
        loadProducts(silent: true);
        return true;
      },
    );
  }

  Future<bool> updateProduct(int id, Map<String, dynamic> data) async {
    if (state is AdminProductsLoaded) {
      final current = state as AdminProductsLoaded;
      emit(current.copyWith(isSubmitting: true));
    }

    final result = await repository.updateProduct(id, data);
    return result.fold(
      (failure) {
        if (state is AdminProductsLoaded) {
          final current = state as AdminProductsLoaded;
          emit(current.copyWith(isSubmitting: false));
        }
        return false;
      },
      (updatedProduct) {
        loadProducts(silent: true);
        return true;
      },
    );
  }

  Future<bool> deleteProduct(int id) async {
    final result = await repository.deleteProduct(id);
    return result.fold(
      (failure) => false,
      (_) {
        loadProducts(silent: true);
        return true;
      },
    );
  }

  Future<bool> updateStockQuantity(int id, double newStock) async {
    return await updateProduct(id, {'stock_quantity': newStock});
  }

  Future<bool> toggleAvailability(int id, bool isAvailable) async {
    // optimistic update
    if (state is AdminProductsLoaded) {
      final current = state as AdminProductsLoaded;
      final updatedList = current.allProducts.map((p) {
        if (p.id == id) {
          return Product(
            id: p.id,
            title: p.title,
            titleAr: p.titleAr,
            titleEn: p.titleEn,
            subtitle: p.subtitle,
            description: p.description,
            sku: p.sku,
            barcode: p.barcode,
            price: p.price,
            purchasePrice: p.purchasePrice,
            originalPrice: p.originalPrice,
            offerPrice: p.offerPrice,
            profit: p.profit,
            profitPercentage: p.profitPercentage,
            discountType: p.discountType,
            discountValue: p.discountValue,
            offerStartDate: p.offerStartDate,
            offerEndDate: p.offerEndDate,
            isOnOffer: p.isOnOffer,
            imageUrl: p.imageUrl,
            discountTag: p.discountTag,
            isOffer: p.isOffer,
            isFeatured: p.isFeatured,
            isBestSeller: p.isBestSeller,
            isAvailable: isAvailable,
            active: isAvailable,
            stockQuantity: isAvailable ? (p.stockQuantity ?? 10) : 0,
            minimumStock: p.minimumStock,
            weightKg: p.weightKg,
            preparationTimeMin: p.preparationTimeMin,
            categoryId: p.categoryId,
            categoryName: p.categoryName,
            loyaltyPoints: p.loyaltyPoints,
            cuttingOptions: p.cuttingOptions,
            packagingOptions: p.packagingOptions,
            excludedParts: p.excludedParts,
            galleryImages: p.galleryImages,
          );
        }
        return p;
      }).toList();
      emit(current.copyWith(allProducts: updatedList));
    }

    final result = await repository.toggleProductAvailability(id, isAvailable);
    return result.fold(
      (failure) {
        loadProducts(silent: true);
        return false;
      },
      (product) => true,
    );
  }
}
