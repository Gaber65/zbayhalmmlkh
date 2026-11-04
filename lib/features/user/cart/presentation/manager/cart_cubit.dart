import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/repositories/cart_repository.dart';
import 'cart_state.dart';

@injectable
class CartCubit extends Cubit<CartState> {
  final CartRepository repository;

  CartCubit({required this.repository}) : super(CartInitial());

  Future<void> fetchCart() async {
    if (!isClosed) emit(CartLoading());
    final result = await repository.getCart();
    result.fold(
      (failure) => if (!isClosed) emit(CartError(failure.error.message)),
      (cart) => if (!isClosed) emit(CartLoaded(cart)),
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
    if (!isClosed) emit(CartItemAdding());
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
      (failure) => if (!isClosed) emit(CartItemAddError(failure.error.message)),
      (cart) => if (!isClosed) emit(CartItemAdded(cart)),
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
    if (!isClosed) emit(CartLoading());
    final result = await repository.updateCartItem(
      productId: productId,
      quantity: quantity,
      cuttingOptionId: cuttingOptionId,
      packagingIds: packagingIds,
      excludedPartIds: excludedPartIds,
      notes: notes,
    );
    result.fold(
      (failure) => if (!isClosed) emit(CartError(failure.error.message)),
      (cart) => if (!isClosed) emit(CartLoaded(cart)),
    );
  }

  Future<void> removeFromCart({required int productId}) async {
    if (!isClosed) emit(CartLoading());
    final result = await repository.removeFromCart(productId: productId);
    result.fold(
      (failure) => if (!isClosed) emit(CartError(failure.error.message)),
      (cart) => if (!isClosed) emit(CartLoaded(cart)),
    );
  }

  Future<void> clearCart() async {
    if (!isClosed) emit(CartLoading());
    final result = await repository.clearCart();
    result.fold(
      (failure) => if (!isClosed) emit(CartError(failure.error.message)),
      (cart) => if (!isClosed) emit(CartLoaded(cart)),
    );
  }
}
