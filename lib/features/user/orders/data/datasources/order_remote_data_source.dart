import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:dhabayih_lmamlaka/core/api/server_strings.dart';
import 'package:dhabayih_lmamlaka/core/error/exceptions.dart';
import 'package:dhabayih_lmamlaka/core/network/error_message_model.dart';
import '../models/order_model.dart';
import '../models/payment_method_model.dart';
import '../../domain/entities/branch_entity.dart';

abstract class OrderRemoteDataSource {
  Future<Map<String, dynamic>> getCheckoutSummary();

  Future<CheckoutResultModel> checkout({
    required String deliveryType,
    int? addressId,
    int? branchId,
    required int paymentMethodId,
    String? notes,
    String? couponCode,
    bool? redeemPoints,
  });

  Future<List<OrderListItemModel>> getOrders({
    String? state,
    int? limit,
    int? offset,
  });

  Future<OrderDetailModel> getOrderDetail(int orderId);

  Future<void> cancelOrder(int orderId);

  Future<void> receiveOrder(int orderId);

  Future<String> applyCoupon(String code, {int? orderId});

  Future<String> removeCoupon({int? orderId});

  Future<List<PaymentMethodModel>> getPaymentMethods();

  Future<CheckoutResultModel> verifyPayment(int orderId, String paymentId);

  Future<CheckoutResultModel> switchPaymentMethod(int orderId, String paymentMethodCode);
  Future<List<BranchEntity>> getBranches();
}

@LazySingleton(as: OrderRemoteDataSource)
class OrderRemoteDataSourceImpl with DioErrorHandler implements OrderRemoteDataSource {
  final Dio dio;

  OrderRemoteDataSourceImpl({required this.dio});

  ServerException _serverException(dynamic data) => ServerException(
        errorMessageModel: ErrorMessageModel.fromJson(
          data is Map<String, dynamic> ? data : {},
        ),
      );

  @override
  Future<Map<String, dynamic>> getCheckoutSummary() async {
    try {
      final response = await dio.get('/api/v1/checkout/summary');
      if (response.statusCode == 200) {
        final dynamic data = response.data['data'] ?? response.data;
        return data as Map<String, dynamic>;
      }
      throw _serverException(response.data);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<CheckoutResultModel> checkout({
    required String deliveryType,
    int? addressId,
    int? branchId,
    required int paymentMethodId,
    String? notes,
    String? couponCode,
    bool? redeemPoints,
  }) async {
    try {
      final body = {
        'delivery_type': deliveryType,
        'payment_method_id': paymentMethodId,
        'address_id': ?addressId,
        'branch_id': ?branchId,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
        if (couponCode != null && couponCode.isNotEmpty) 'coupon_code': couponCode,
        'redeem_points': ?redeemPoints,
      };

      final response = await dio.post(ServerStrings.checkout, data: body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final dynamic data = response.data['data'] ?? response.data;
        return CheckoutResultModel.fromJson(data as Map<String, dynamic>);
      }
      throw _serverException(response.data);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<List<OrderListItemModel>> getOrders({
    String? state,
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = {
        'state': ?state,
        'limit': ?limit,
        'offset': ?offset,
      };

      final response = await dio.get(
        ServerStrings.orders,
        queryParameters: queryParams,
      );
      if (response.statusCode == 200) {
        final dynamic data = response.data['data'] ?? response.data;
        if (data is List) {
          return data
              .map((e) => OrderListItemModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return [];
      }
      throw _serverException(response.data);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<OrderDetailModel> getOrderDetail(int orderId) async {
    try {
      final response = await dio.get(ServerStrings.orderById(orderId));
      if (response.statusCode == 200) {
        final dynamic data = response.data['data'] ?? response.data;
        return OrderDetailModel.fromJson(data as Map<String, dynamic>);
      }
      throw _serverException(response.data);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<void> cancelOrder(int orderId) async {
    try {
      final response = await dio.post(ServerStrings.cancelOrder(orderId));
      if (response.statusCode != 200) {
        throw _serverException(response.data);
      }
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<void> receiveOrder(int orderId) async {
    try {
      final response = await dio.post(ServerStrings.receiveOrder(orderId));
      if (response.statusCode != 200) {
        throw _serverException(response.data);
      }
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<String> applyCoupon(String code, {int? orderId}) async {
    try {
      final body = {
        'code': code,
        'order_id': ?orderId,
      };
      final response = await dio.post(ServerStrings.applyCoupon, data: body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data['message'] as String? ?? 'Coupon applied successfully';
      }
      throw _serverException(response.data);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<String> removeCoupon({int? orderId}) async {
    try {
      final body = {
        'order_id': ?orderId,
      };
      final response = await dio.post(ServerStrings.removeCoupon, data: body);
      if (response.statusCode == 200) {
        return response.data['message'] as String? ?? 'Coupon removed successfully';
      }
      throw _serverException(response.data);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    try {
      final response = await dio.get(ServerStrings.paymentMethods);
      if (response.statusCode == 200) {
        final dynamic data = response.data['data'] ?? response.data;
        if (data is List) {
          return data
              .map((e) => PaymentMethodModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return [];
      }
      throw _serverException(response.data);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<CheckoutResultModel> verifyPayment(int orderId, String paymentId) async {
    try {
      final response = await dio.post(
        '/api/v1/payment/verify',
        data: {
          'order_id': orderId,
          'payment_id': paymentId,
        },
      );
      if (response.statusCode == 200) {
        final dynamic data = response.data['data'] ?? response.data;
        return CheckoutResultModel.fromJson(data as Map<String, dynamic>);
      }
      throw _serverException(response.data);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<CheckoutResultModel> switchPaymentMethod(int orderId, String paymentMethodCode) async {
    try {
      final response = await dio.post(
        '/api/v1/orders/$orderId/switch-payment-method',
        data: {
          'payment_method_code': paymentMethodCode,
        },
      );
      if (response.statusCode == 200) {
        final dynamic data = response.data['data'] ?? response.data;
        return CheckoutResultModel.fromJson(data as Map<String, dynamic>);
      }
      throw _serverException(response.data);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<List<BranchEntity>> getBranches() async {
    try {
      final response = await dio.get(ServerStrings.branches);
      final dynamic raw = response.data['data'] ?? response.data;
      if (raw is List) {
        return raw.map((b) => BranchEntity.fromJson(Map<String, dynamic>.from(b as Map))).toList();
      }
      return [];
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }
}
