import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import 'order_state.dart';

@injectable
class OrderCubit extends Cubit<OrderState> {
  final OrderRepository repository;

  OrderCubit({required this.repository}) : super(OrderInitial());

  List<OrderListItemEntity> _allOrders = [];
  bool _hasMore = true;
  bool _isLoadingMore = false;
  static const int _pageSize = 15;

  List<OrderListItemEntity> get currentOrders => _allOrders;
  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  void _safeEmit(OrderState state) {
    if (!isClosed) {
      emit(state);
    }
  }

  /// Initial load or refresh of orders with pagination reset
  Future<void> fetchOrders({
    String? state,
    int limit = _pageSize,
    int offset = 0,
  }) async {
    _safeEmit(OrderLoading());
    _hasMore = true;
    _isLoadingMore = false;

    final result = await repository.getOrders(
      state: state,
      limit: limit,
      offset: offset,
    );

    result.fold(
      (failure) => _safeEmit(OrderError(failure.error.message)),
      (orders) {
        _allOrders = List.from(orders);
        if (orders.length < limit) {
          _hasMore = false;
        }
        _safeEmit(OrderListLoaded(_allOrders));
      },
    );
  }

  /// Load more orders appended to the current list without full screen flicker (Infinite Scroll)
  Future<void> loadMoreOrders({String? state}) async {
    if (!_hasMore || _isLoadingMore) return;

    _isLoadingMore = true;
    final currentOffset = _allOrders.length;

    final result = await repository.getOrders(
      state: state,
      limit: _pageSize,
      offset: currentOffset,
    );

    result.fold(
      (failure) {
        _isLoadingMore = false;
        // Keep current orders on pagination error, don't crash the list
        _safeEmit(OrderListLoaded(_allOrders));
      },
      (newOrders) {
        _isLoadingMore = false;
        if (newOrders.isEmpty || newOrders.length < _pageSize) {
          _hasMore = false;
        }
        _allOrders.addAll(newOrders);
        _safeEmit(OrderListLoaded(List.from(_allOrders)));
      },
    );
  }

  Future<void> fetchOrderDetail(int orderId) async {
    _safeEmit(OrderLoading());
    final result = await repository.getOrderDetail(orderId);
    result.fold(
      (failure) => _safeEmit(OrderError(failure.error.message)),
      (order) => _safeEmit(OrderDetailLoaded(order)),
    );
  }

  Future<void> cancelOrder(int orderId) async {
    _safeEmit(OrderCancelLoading());
    final result = await repository.cancelOrder(orderId);
    result.fold(
      (failure) => _safeEmit(OrderCancelError(failure.error.message)),
      (_) => _safeEmit(OrderCancelSuccess(orderId, 'cancel_order_success')),
    );
  }

  Future<void> receiveOrder(int orderId) async {
    _safeEmit(OrderReceiveLoading());
    final result = await repository.receiveOrder(orderId);
    result.fold(
      (failure) => _safeEmit(OrderReceiveError(failure.error.message)),
      (_) => _safeEmit(OrderReceiveSuccess(orderId, 'تم تأكيد الاستلام بنجاح')),
    );
  }
}
