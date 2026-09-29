import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:dhabayih_lmamlaka/core/api/server_strings.dart';
import 'package:dhabayih_lmamlaka/core/error/exceptions.dart';
import '../models/cart_model.dart';

abstract class CartRemoteDataSource {
  Future<CartModel> getCart();
  Future<CartModel> addToCart({
    required int productId,
    required double quantity,
    int? cuttingOptionId,
    List<int>? packagingIds,
    List<int>? excludedPartIds,
    String? notes,
    int? sizeId,
  });
  Future<CartModel> updateCartItem({
    required int productId,
    required double quantity,
    int? cuttingOptionId,
    List<int>? packagingIds,
    List<int>? excludedPartIds,
    String? notes,
  });
  Future<CartModel> removeFromCart({required int productId});
  Future<CartModel> clearCart();
}

@LazySingleton(as: CartRemoteDataSource)
class CartRemoteDataSourceImpl with DioErrorHandler implements CartRemoteDataSource {
  final Dio dio;
  CartRemoteDataSourceImpl({required this.dio});

  CartModel _parseCart(Response response) {
    final data = response.data;
    final cartData = data['data']?['cart'] ?? data['data'] ?? data['cart'] ?? data;
    return CartModel.fromJson(cartData as Map<String, dynamic>);
  }



  @override
  Future<CartModel> getCart() async {
    try {
      final response = await dio.get(ServerStrings.cart);
      return _parseCart(response);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<CartModel> addToCart({
    required int productId,
    required double quantity,
    int? cuttingOptionId,
    List<int>? packagingIds,
    List<int>? excludedPartIds,
    String? notes,
    int? sizeId,
  }) async {
    try {
      final body = <String, dynamic>{
        'product_id': productId,
        'quantity': quantity,
        if (cuttingOptionId != null) 'cutting_option_id': cuttingOptionId,
        if (sizeId != null) 'size_id': sizeId,
        if (packagingIds != null && packagingIds.isNotEmpty) 'packaging_ids': packagingIds,
        if (excludedPartIds != null && excludedPartIds.isNotEmpty) 'excluded_part_ids': excludedPartIds,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      };
      final response = await dio.post(ServerStrings.addToCart, data: body);
      return _parseCart(response);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<CartModel> updateCartItem({
    required int productId,
    required double quantity,
    int? cuttingOptionId,
    List<int>? packagingIds,
    List<int>? excludedPartIds,
    String? notes,
  }) async {
    try {
      final body = <String, dynamic>{
        'product_id': productId,
        'quantity': quantity,
        'cutting_option_id': ?cuttingOptionId,
        'packaging_ids': ?packagingIds,
        'excluded_part_ids': ?excludedPartIds,
        'notes': ?notes,
      };
      final response = await dio.put(ServerStrings.updateCart, data: body);
      return _parseCart(response);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<CartModel> removeFromCart({required int productId}) async {
    try {
      final response = await dio.delete(ServerStrings.removeCartItem(productId));
      return _parseCart(response);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<CartModel> clearCart() async {
    try {
      final response = await dio.delete(ServerStrings.clearCart);
      return _parseCart(response);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

}
