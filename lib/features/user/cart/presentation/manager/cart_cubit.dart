import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/repositories/cart_repository.dart';
import 'cart_state.dart';

@injectable
class CartCubit extends Cubit<CartState> {
  final CartRepository repository;

  CartCubit({required this.repository}) : super(CartInitial());

  Future<void> fetchCart() async {
    emit(CartLoading());
    final result = await repository.getCart();
    result.fold(
      (failure) => emit(CartError(failure.error.message)),
      (cart) => emit(CartLoaded(cart)),
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
    emit(CartItemAdding());
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
      (failure) => emit(CartItemAddError(failure.error.message)),
      (cart) => emit(CartItemAdded(cart)),
    );
  }

  Future<void> updateCartItem({
    required int productId,
    required double quantity,
    int? cuttingOptionId,
    List<int>? packagingIds,
    List<int>? excludedPartIds,
    String? notes,
  }) async {
    emit(CartLoading());
    final result = await repository.updateCartItem(
      productId: productId,
      quantity: quantity,
      cuttingOptionId: cuttingOptionId,
      packagingIds: packagingIds,
      excludedPartIds: excludedPartIds,
      notes: notes,
    );
    result.fold(
      (failure) => emit(CartError(failure.error.message)),
      (cart) => emit(CartLoaded(cart)),
    );
  }

  Future<void> removeFromCart({required int productId}) async {
    emit(CartLoading());
    final result = await repository.removeFromCart(productId: productId);
    result.fold(
      (failure) => emit(CartError(failure.error.message)),
      (cart) => emit(CartLoaded(cart)),
    );
  }

  Future<void> clearCart() async {
    emit(CartLoading());
    final result = await repository.clearCart();
    result.fold(
      (failure) => emit(CartError(failure.error.message)),
      (cart) => emit(CartLoaded(cart)),
    );
  }
}
