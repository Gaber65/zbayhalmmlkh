import 'package:equatable/equatable.dart';
import '../../domain/entities/order_entity.dart';

abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrderListLoaded extends OrderState {
  final List<OrderListItemEntity> orders;

  const OrderListLoaded(this.orders);

  @override
  List<Object?> get props => [orders];
}

class OrderDetailLoaded extends OrderState {
  final OrderDetailEntity order;

  const OrderDetailLoaded(this.order);

  @override
  List<Object?> get props => [order];
}

class OrderError extends OrderState {
  final String message;

  const OrderError(this.message);

  @override
  List<Object?> get props => [message];
}

class OrderCancelLoading extends OrderState {}

class OrderCancelSuccess extends OrderState {
  final int orderId;
  final String message;

  const OrderCancelSuccess(this.orderId, this.message);

  @override
  List<Object?> get props => [orderId, message];
}

class OrderCancelError extends OrderState {
  final String message;

  const OrderCancelError(this.message);

  @override
  List<Object?> get props => [message];
}

class OrderReceiveLoading extends OrderState {}

class OrderReceiveSuccess extends OrderState {
  final int orderId;
  final String message;

  const OrderReceiveSuccess(this.orderId, this.message);

  @override
  List<Object?> get props => [orderId, message];
}

class OrderReceiveError extends OrderState {
  final String message;

  const OrderReceiveError(this.message);

  @override
  List<Object?> get props => [message];
}
