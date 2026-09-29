import 'package:equatable/equatable.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/payment_method_entity.dart';
import '../../domain/entities/checkout_summary_entity.dart';

abstract class CheckoutState extends Equatable {
  const CheckoutState();

  @override
  List<Object?> get props => [];
}

class CheckoutInitial extends CheckoutState {}

class CheckoutSummaryLoading extends CheckoutState {}

class CheckoutSummaryLoaded extends CheckoutState {
  final CheckoutSummaryEntity summary;

  const CheckoutSummaryLoaded(this.summary);

  @override
  List<Object?> get props => [summary];
}

class CheckoutLoading extends CheckoutState {}

class CheckoutSuccess extends CheckoutState {
  final CheckoutResultEntity result;

  const CheckoutSuccess(this.result);

  @override
  List<Object?> get props => [result];
}

class CheckoutError extends CheckoutState {
  final String message;

  const CheckoutError(this.message);

  @override
  List<Object?> get props => [message];
}

class CouponApplied extends CheckoutState {
  final String message;
  final String code;

  const CouponApplied({required this.message, required this.code});

  @override
  List<Object?> get props => [message, code];
}

class CouponRemoved extends CheckoutState {
  final String message;

  const CouponRemoved(this.message);

  @override
  List<Object?> get props => [message];
}

class PaymentMethodsLoading extends CheckoutState {}

class PaymentMethodsLoaded extends CheckoutState {
  final List<PaymentMethodEntity> methods;

  const PaymentMethodsLoaded(this.methods);

  @override
  List<Object?> get props => [methods];
}

class PaymentMethodsError extends CheckoutState {
  final String message;

  const PaymentMethodsError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Emitted after [CheckoutCubit.verifyPayment] succeeds.
/// Distinct from [CheckoutSuccess] to avoid re-triggering the payment flow.
class PaymentVerified extends CheckoutState {
  final CheckoutResultEntity result;

  const PaymentVerified(this.result);

  @override
  List<Object?> get props => [result];
}

/// Emitted after [CheckoutCubit.switchPaymentMethod] succeeds.
/// Distinct from [CheckoutSuccess] to prevent re-running the online payment
/// flow when [_selectedPaymentMethod] still holds an online provider reference.
class PaymentMethodSwitched extends CheckoutState {
  final CheckoutResultEntity result;

  const PaymentMethodSwitched(this.result);

  @override
  List<Object?> get props => [result];
}

class OrderCancelled extends CheckoutState {
  final String message;

  const OrderCancelled([this.message = 'تم إلغاء الطلب بنجاح']);

  @override
  List<Object?> get props => [message];
}
