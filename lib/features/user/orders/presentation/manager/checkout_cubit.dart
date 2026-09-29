import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/entities/branch_entity.dart';
import 'checkout_state.dart';

@injectable
class CheckoutCubit extends Cubit<CheckoutState> {
  final OrderRepository repository;

  CheckoutCubit({required this.repository}) : super(CheckoutInitial());

  String? appliedCouponCode;

  Future<List<BranchEntity>> getBranches() async {
    final result = await repository.getBranches();
    return result.fold(
      (failure) => [],
      (branches) => branches,
    );
  }

  Future<void> fetchCheckoutSummary() async {
    emit(CheckoutSummaryLoading());
    final result = await repository.getCheckoutSummary();
    result.fold(
      (failure) => emit(CheckoutError(failure.error.message)),
      (summary) => emit(CheckoutSummaryLoaded(summary)),
    );
  }

  Future<void> checkout({
    required String deliveryType,
    int? addressId,
    int? branchId,
    required int paymentMethodId,
    String? notes,
    String? couponCode,
    bool? redeemPoints,
  }) async {
    emit(CheckoutLoading());
    final effectiveCouponCode = (couponCode != null && couponCode.isNotEmpty)
        ? couponCode
        : appliedCouponCode;

    final result = await repository.checkout(
      deliveryType: deliveryType,
      addressId: addressId,
      branchId: branchId,
      paymentMethodId: paymentMethodId,
      notes: notes,
      couponCode: effectiveCouponCode,
      redeemPoints: redeemPoints,
    );
    result.fold(
      (failure) => emit(CheckoutError(failure.error.message)),
      (success) => emit(CheckoutSuccess(success)),
    );
  }

  Future<void> applyCoupon(String code, {int? orderId}) async {
    if (orderId != null) {
      emit(CheckoutLoading());
      final result = await repository.applyCoupon(code, orderId: orderId);
      result.fold(
        (failure) => emit(CheckoutError(failure.error.message)),
        (message) {
          appliedCouponCode = code;
          emit(CouponApplied(message: message, code: code));
        },
      );
    } else {
      appliedCouponCode = code;
      emit(CouponApplied(
        message: 'تم تطبيق رمز الكوبون بنجاح وسيتم حسابه عند إتمام الطلب',
        code: code,
      ));
    }
  }

  Future<void> removeCoupon({int? orderId}) async {
    if (orderId != null) {
      emit(CheckoutLoading());
      final result = await repository.removeCoupon(orderId: orderId);
      result.fold(
        (failure) => emit(CheckoutError(failure.error.message)),
        (message) {
          appliedCouponCode = null;
          emit(CouponRemoved(message));
        },
      );
    } else {
      appliedCouponCode = null;
      emit(const CouponRemoved('تم إزالة رمز الكوبون'));
    }
  }

  Future<void> fetchPaymentMethods() async {
    emit(PaymentMethodsLoading());
    final result = await repository.getPaymentMethods();
    result.fold(
      (failure) => emit(PaymentMethodsError(failure.error.message)),
      (methods) => emit(PaymentMethodsLoaded(methods)),
    );
  }

  Future<void> verifyPayment(int orderId, String paymentId) async {
    emit(CheckoutLoading());
    final result = await repository.verifyPayment(orderId, paymentId);
    result.fold(
      (failure) => emit(CheckoutError(failure.error.message)),
      // Emit PaymentVerified (not CheckoutSuccess) so the listener routes
      // to OrderSuccessScreen instead of re-triggering the payment flow.
      (success) => emit(PaymentVerified(success)),
    );
  }

  Future<void> switchPaymentMethod(int orderId, String paymentMethodCode) async {
    emit(CheckoutLoading());
    final result = await repository.switchPaymentMethod(orderId, paymentMethodCode);
    result.fold(
      (failure) => emit(CheckoutError(failure.error.message)),
      // Emit PaymentMethodSwitched (NOT CheckoutSuccess) to prevent the
      // BlocListener from re-triggering the online payment flow when
      // _selectedPaymentMethod still holds an online provider.
      (success) => emit(PaymentMethodSwitched(success)),
    );
  }

  Future<void> cancelOrder(int orderId) async {
    emit(CheckoutLoading());
    final result = await repository.cancelOrder(orderId);
    result.fold(
      (failure) => emit(CheckoutError(failure.error.message)),
      (_) => emit(const OrderCancelled()),
    );
  }
}
