import 'package:dartz/dartz.dart';
import 'package:dhabayih_lmamlaka/core/error/failure.dart';
import '../entities/order_entity.dart';
import '../entities/payment_method_entity.dart';
import '../entities/checkout_summary_entity.dart';
import '../entities/branch_entity.dart';

abstract class OrderRepository {
  Future<Either<Failure, CheckoutSummaryEntity>> getCheckoutSummary();
  Future<Either<Failure, CheckoutResultEntity>> checkout({
    required String deliveryType,
    int? addressId,
    int? branchId,
    required int paymentMethodId,
    String? notes,
    String? couponCode,
    bool? redeemPoints,
  });

  Future<Either<Failure, List<OrderListItemEntity>>> getOrders({
    String? state,
    int? limit,
    int? offset,
  });

  Future<Either<Failure, OrderDetailEntity>> getOrderDetail(int orderId);

  Future<Either<Failure, void>> cancelOrder(int orderId);

  Future<Either<Failure, void>> receiveOrder(int orderId);

  Future<Either<Failure, String>> applyCoupon(String code, {int? orderId});

  Future<Either<Failure, String>> removeCoupon({int? orderId});

  Future<Either<Failure, List<PaymentMethodEntity>>> getPaymentMethods();

  Future<Either<Failure, CheckoutResultEntity>> verifyPayment(int orderId, String paymentId);

  Future<Either<Failure, CheckoutResultEntity>> switchPaymentMethod(int orderId, String paymentMethodCode);

  Future<Either<Failure, List<BranchEntity>>> getBranches();
}
