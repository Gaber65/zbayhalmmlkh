import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:dhabayih_lmamlaka/core/error/exceptions.dart';
import 'package:dhabayih_lmamlaka/core/error/failure.dart';
import 'package:dhabayih_lmamlaka/core/network/error_message_model.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/payment_method_entity.dart';
import '../../domain/entities/checkout_summary_entity.dart';
import '../../domain/entities/branch_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_data_source.dart';

@LazySingleton(as: OrderRepository)
class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;

  OrderRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, CheckoutSummaryEntity>> getCheckoutSummary() async {
    try {
      final json = await remoteDataSource.getCheckoutSummary();
      return Right(CheckoutSummaryEntity.fromJson(json));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorMessageModel));
    } catch (e) {
      return Left(ServerFailure(_unknownError(e)));
    }
  }

  @override
  Future<Either<Failure, CheckoutResultEntity>> checkout({
    required String deliveryType,
    int? addressId,
    int? branchId,
    required int paymentMethodId,
    String? notes,
    String? couponCode,
    bool? redeemPoints,
  }) async {
    try {
      final model = await remoteDataSource.checkout(
        deliveryType: deliveryType,
        addressId: addressId,
        branchId: branchId,
        paymentMethodId: paymentMethodId,
        notes: notes,
        couponCode: couponCode,
        redeemPoints: redeemPoints,
      );
      return Right(model.toDomain());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorMessageModel));
    } catch (e) {
      return Left(ServerFailure(_unknownError(e)));
    }
  }

  @override
  Future<Either<Failure, List<OrderListItemEntity>>> getOrders({
    String? state,
    int? limit,
    int? offset,
  }) async {
    try {
      final models = await remoteDataSource.getOrders(
        state: state,
        limit: limit,
        offset: offset,
      );
      return Right(models.map((m) => m.toDomain()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorMessageModel));
    } catch (e) {
      return Left(ServerFailure(_unknownError(e)));
    }
  }

  @override
  Future<Either<Failure, OrderDetailEntity>> getOrderDetail(int orderId) async {
    try {
      final model = await remoteDataSource.getOrderDetail(orderId);
      return Right(model.toDomain());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorMessageModel));
    } catch (e) {
      return Left(ServerFailure(_unknownError(e)));
    }
  }

  @override
  Future<Either<Failure, void>> cancelOrder(int orderId) async {
    try {
      await remoteDataSource.cancelOrder(orderId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorMessageModel));
    } catch (e) {
      return Left(ServerFailure(_unknownError(e)));
    }
  }

  @override
  Future<Either<Failure, void>> receiveOrder(int orderId) async {
    try {
      await remoteDataSource.receiveOrder(orderId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorMessageModel));
    } catch (e) {
      return Left(ServerFailure(_unknownError(e)));
    }
  }

  @override
  Future<Either<Failure, String>> applyCoupon(String code, {int? orderId}) async {
    try {
      final msg = await remoteDataSource.applyCoupon(code, orderId: orderId);
      return Right(msg);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorMessageModel));
    } catch (e) {
      return Left(ServerFailure(_unknownError(e)));
    }
  }

  @override
  Future<Either<Failure, String>> removeCoupon({int? orderId}) async {
    try {
      final msg = await remoteDataSource.removeCoupon(orderId: orderId);
      return Right(msg);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorMessageModel));
    } catch (e) {
      return Left(ServerFailure(_unknownError(e)));
    }
  }

  @override
  Future<Either<Failure, List<PaymentMethodEntity>>> getPaymentMethods() async {
    try {
      final models = await remoteDataSource.getPaymentMethods();
      return Right(models.map((m) => m.toDomain()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorMessageModel));
    } catch (e) {
      return Left(ServerFailure(_unknownError(e)));
    }
  }

  @override
  Future<Either<Failure, CheckoutResultEntity>> verifyPayment(int orderId, String paymentId) async {
    try {
      final model = await remoteDataSource.verifyPayment(orderId, paymentId);
      return Right(model.toDomain());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorMessageModel));
    } catch (e) {
      return Left(ServerFailure(_unknownError(e)));
    }
  }

  @override
  Future<Either<Failure, CheckoutResultEntity>> switchPaymentMethod(int orderId, String paymentMethodCode) async {
    try {
      final model = await remoteDataSource.switchPaymentMethod(orderId, paymentMethodCode);
      return Right(model.toDomain());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorMessageModel));
    } catch (e) {
      return Left(ServerFailure(_unknownError(e)));
    }
  }

  @override
  Future<Either<Failure, List<BranchEntity>>> getBranches() async {
    try {
      final branches = await remoteDataSource.getBranches();
      return Right(branches);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorMessageModel));
    } catch (e) {
      return Left(ServerFailure(_unknownError(e)));
    }
  }

  ErrorMessageModel _unknownError(Object e) => ErrorMessageModel(
        message: e.toString(),
        errors: [],
        success: false,
        statusCode: 500,
      );
}
