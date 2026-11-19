import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/cart.dart';
import '../../domain/repositories/cart_repository.dart';
import 'cart_state.dart';

@lazySingleton
class CartCubit extends Cubit<CartState> {
  final CartRepository repository;

  CartCubit({required this.repository}) : super(CartInitial());

  CartEntity? _currentCart;

  CartEntity? get currentCart => _currentCart;

  void _safeEmit(CartState state) {
    if (!isClosed) {
      emit(state);
    }
  }

  Future<void> fetchCart() async {
    _safeEmit(CartLoading());
    final result = await repository.getCart();
    result.fold(
      (failure) => _safeEmit(CartError(failure.error.message)),
      (cart) {
        _currentCart = cart;
        _safeEmit(CartLoaded(cart));
      },
    );
  }

  Future<void> addToCart({
    required int productId,
    required double quantity,
    int? cuttingOptionId,
    List<int>? packagingIds,
    List<int>? excludedPartIds,
    String? notes,
    int? sizeId,
  }) async {
    _safeEmit(CartItemAdding());
    final result = await repository.addToCart(
      productId: productId,
      quantity: quantity,
      cuttingOptionId: cuttingOptionId,
      packagingIds: packagingIds,
      excludedPartIds: excludedPartIds,
      notes: notes,
      sizeId: sizeId,
    );
    result.fold(
      (failure) => _safeEmit(CartItemAddError(failure.error.message)),
      (cart) {
        _currentCart = cart;
        _safeEmit(CartItemAdded(cart));
      },
    );
  }

  /// Optimistically update cart item quantity immediately without waiting for server response.
  /// If server request fails, rolls back to previous cart state seamlessly.
  Future<void> updateCartItem({
    required int productId,
    required double quantity,
    int? cuttingOptionId,
    List<int>? packagingIds,
    List<int>? excludedPartIds,
    String? notes,
  }) async {
    final previousCart = _currentCart;

    // Apply Optimistic Update if we have existing cart loaded
    if (_currentCart != null) {
      final updatedLines = _currentCart!.lines.map((line) {
        if (line.productId == productId) {
          final unitPrice = line.priceUnit;
          final newLineTotal = unitPrice * quantity;
          return CartLineEntity(
            id: line.id,
            productId: line.productId,
            productName: line.productName,
            productImageUrl: line.productImageUrl,
            quantity: quantity,
            priceUnit: line.priceUnit,
            discountPercent: line.discountPercent,
            lineTotal: newLineTotal,
            sizeId: line.sizeId,
            sizeName: line.sizeName,
            sizePrice: line.sizePrice,
            cuttingPrice: line.cuttingPrice,
            packagingPrice: line.packagingPrice,
            cuttingOption: line.cuttingOption,
            packagingOptions: line.packagingOptions,
            excludedParts: line.excludedParts,
            notes: line.notes,
          );
        }
        return line;
      }).toList();

      final newTotal = updatedLines.fold<double>(0.0, (sum, item) => sum + item.lineTotal);
      final optimisticCart = CartEntity(
        id: _currentCart!.id,
        status: _currentCart!.status,
        lines: updatedLines,
        subtotal: newTotal,
        total: newTotal,
        itemCount: updatedLines.length,
      );

      _currentCart = optimisticCart;
      _safeEmit(CartLoaded(optimisticCart));
    }

    final result = await repository.updateCartItem(
      productId: productId,
      quantity: quantity,
      cuttingOptionId: cuttingOptionId,
      packagingIds: packagingIds,
      excludedPartIds: excludedPartIds,
      notes: notes,
    );

    result.fold(
      (failure) {
        // Rollback on failure
        if (previousCart != null) {
          _currentCart = previousCart;
          _safeEmit(CartLoaded(previousCart));
        }
        _safeEmit(CartError(failure.error.message));
      },
      (cart) {
        _currentCart = cart;
        _safeEmit(CartLoaded(cart));
      },
    );
  }

  /// Optimistically remove product from cart.
  Future<void> removeFromCart({required int productId}) async {
    final previousCart = _currentCart;

    if (_currentCart != null) {
      final updatedLines = _currentCart!.lines.where((l) => l.productId != productId).toList();
      final newTotal = updatedLines.fold<double>(0.0, (sum, item) => sum + item.lineTotal);
      final optimisticCart = CartEntity(
        id: _currentCart!.id,
        status: _currentCart!.status,
        lines: updatedLines,
        subtotal: newTotal,
        total: newTotal,
        itemCount: updatedLines.length,
      );

      _currentCart = optimisticCart;
      _safeEmit(CartLoaded(optimisticCart));
    }

    final result = await repository.removeFromCart(productId: productId);
    result.fold(
      (failure) {
        if (previousCart != null) {
          _currentCart = previousCart;
          _safeEmit(CartLoaded(previousCart));
        }
        _safeEmit(CartError(failure.error.message));
      },
      (cart) {
        _currentCart = cart;
        _safeEmit(CartLoaded(cart));
      },
    );
  }

  Future<void> clearCart() async {
    _safeEmit(CartLoading());
    final result = await repository.clearCart();
    result.fold(
      (failure) => _safeEmit(CartError(failure.error.message)),
      (cart) {
        _currentCart = cart;
        _safeEmit(CartLoaded(cart));
      },
    );
  }
}
