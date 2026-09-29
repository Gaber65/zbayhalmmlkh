import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/services/notification_service.dart';
import '../../../user/orders/domain/entities/order_entity.dart';
import '../../domain/repositories/admin_repository.dart';

abstract class AdminOrdersState extends Equatable {
  const AdminOrdersState();
  @override
  List<Object?> get props => [];
}

class AdminOrdersInitial extends AdminOrdersState {}

class AdminOrdersLoading extends AdminOrdersState {}

class AdminOrdersLoaded extends AdminOrdersState {
  final List<OrderListItemEntity> orders;
  final String activeFilter;
  final String searchQuery;
  final OrderDetailEntity? selectedOrderDetail;
  final bool isUpdating;
  final bool hasReachedMax;
  final bool isLoadingMore;

  const AdminOrdersLoaded({
    required this.orders,
    this.activeFilter = 'all',
    this.searchQuery = '',
    this.selectedOrderDetail,
    this.isUpdating = false,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
  });

  AdminOrdersLoaded copyWith({
    List<OrderListItemEntity>? orders,
    String? activeFilter,
    String? searchQuery,
    OrderDetailEntity? selectedOrderDetail,
    bool? isUpdating,
    bool? hasReachedMax,
    bool? isLoadingMore,
  }) {
    return AdminOrdersLoaded(
      orders: orders ?? this.orders,
      activeFilter: activeFilter ?? this.activeFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedOrderDetail: selectedOrderDetail ?? this.selectedOrderDetail,
      isUpdating: isUpdating ?? this.isUpdating,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [
        orders,
        activeFilter,
        searchQuery,
        selectedOrderDetail,
        isUpdating,
        hasReachedMax,
        isLoadingMore,
      ];
}

class AdminOrdersError extends AdminOrdersState {
  final String message;
  const AdminOrdersError({required this.message});
  @override
  List<Object?> get props => [message];
}

@injectable
class AdminOrdersCubit extends Cubit<AdminOrdersState> {
  final AdminRepository repository;
  StreamSubscription? _alertSub;

  AdminOrdersCubit({required this.repository}) : super(AdminOrdersInitial()) {
    _listenToIncomingOrders();
  }

  void _listenToIncomingOrders() {
    _alertSub = NotificationService().adminOrderAlertStream.listen((data) {
      // Auto reload orders on incoming notification
      loadOrders(silent: true);
    });
  }

  @override
  Future<void> close() {
    _alertSub?.cancel();
    return super.close();
  }

  String _currentFilter = 'all';
  String _currentQuery = '';

  Future<void> loadOrders({
    String? state,
    String? query,
    bool silent = false,
  }) async {
    if (state != null) _currentFilter = state;
    if (query != null) _currentQuery = query;

    if (!silent) {
      emit(AdminOrdersLoading());
    }

    final result = await repository.getAdminOrders(
      state: _currentFilter,
      query: _currentQuery,
      limit: 20,
      offset: 0,
    );

    result.fold(
      (failure) => emit(AdminOrdersError(message: failure.error.message)),
      (orders) {
        emit(AdminOrdersLoaded(
          orders: orders,
          activeFilter: _currentFilter,
          searchQuery: _currentQuery,
          hasReachedMax: orders.length < 20,
          isLoadingMore: false,
        ));
      },
    );
  }

  Future<void> loadMoreOrders() async {
    if (state is! AdminOrdersLoaded) return;
    final current = state as AdminOrdersLoaded;
    if (current.hasReachedMax || current.isLoadingMore) return;

    emit(current.copyWith(isLoadingMore: true));

    final result = await repository.getAdminOrders(
      state: _currentFilter,
      query: _currentQuery,
      limit: 20,
      offset: current.orders.length,
    );

    result.fold(
      (failure) => emit(current.copyWith(isLoadingMore: false)),
      (newOrders) {
        if (newOrders.isEmpty) {
          emit(current.copyWith(
            isLoadingMore: false,
            hasReachedMax: true,
          ));
        } else {
          final existingIds = current.orders.map((o) => o.id).toSet();
          final uniqueNew = newOrders.where((o) => !existingIds.contains(o.id)).toList();
          emit(current.copyWith(
            orders: [...current.orders, ...uniqueNew],
            isLoadingMore: false,
            hasReachedMax: newOrders.length < 20,
          ));
        }
      },
    );
  }

  Future<void> setFilter(String status) async {
    _currentFilter = status;
    await loadOrders(state: status);
  }

  Future<void> search(String query) async {
    _currentQuery = query;
    await loadOrders(query: query);
  }

  Future<OrderDetailEntity?> loadOrderDetail(int orderId) async {
    final result = await repository.getAdminOrderDetail(orderId);
    return result.fold(
      (failure) => null,
      (detail) {
        if (state is AdminOrdersLoaded) {
          final current = state as AdminOrdersLoaded;
          emit(current.copyWith(selectedOrderDetail: detail));
        }
        return detail;
      },
    );
  }

  Future<bool> updateOrderStatus(int orderId, String newStatus) async {
    if (state is AdminOrdersLoaded) {
      final current = state as AdminOrdersLoaded;
      emit(current.copyWith(isUpdating: true));
    }

    final result = await repository.updateOrderStatus(orderId, newStatus);
    return result.fold(
      (failure) {
        if (state is AdminOrdersLoaded) {
          final current = state as AdminOrdersLoaded;
          emit(current.copyWith(isUpdating: false));
        }
        return false;
      },
      (updatedDetail) {
        loadOrders(silent: true);
        if (state is AdminOrdersLoaded) {
          final current = state as AdminOrdersLoaded;
          emit(current.copyWith(
            selectedOrderDetail: updatedDetail,
            isUpdating: false,
          ));
        }
        return true;
      },
    );
  }
}
