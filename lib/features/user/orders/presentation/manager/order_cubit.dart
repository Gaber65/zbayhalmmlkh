import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/repositories/order_repository.dart';
import 'order_state.dart';

@injectable
class OrderCubit extends Cubit<OrderState> {
  final OrderRepository repository;

  OrderCubit({required this.repository}) : super(OrderInitial());

  Future<void> fetchOrders({
    String? state,
    int? limit,
    int? offset,
  }) async {
    emit(OrderLoading());
    final result = await repository.getOrders(
      state: state,
      limit: limit,
      offset: offset,
    );
    result.fold(
      (failure) => emit(OrderError(failure.error.message)),
      (orders) => emit(OrderListLoaded(orders)),
    );
  }

  Future<void> fetchOrderDetail(int orderId) async {
    emit(OrderLoading());
    final result = await repository.getOrderDetail(orderId);
    result.fold(
      (failure) => emit(OrderError(failure.error.message)),
      (order) => emit(OrderDetailLoaded(order)),
    );
  }

  Future<void> cancelOrder(int orderId) async {
    emit(OrderCancelLoading());
    final result = await repository.cancelOrder(orderId);
    result.fold(
      (failure) => emit(OrderCancelError(failure.error.message)),
      (_) => emit(OrderCancelSuccess(orderId, 'cancel_order_success')),
    );
  }

  Future<void> receiveOrder(int orderId) async {
    emit(OrderReceiveLoading());
    final result = await repository.receiveOrder(orderId);
    result.fold(
      (failure) => emit(OrderReceiveError(failure.error.message)),
      (_) => emit(OrderReceiveSuccess(orderId, 'تم تأكيد استلام الطلب بنجاح')),
    );
  }
}
