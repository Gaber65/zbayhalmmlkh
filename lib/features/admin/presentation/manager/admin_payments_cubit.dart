import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/admin_entities.dart';
import '../../domain/repositories/admin_repository.dart';

abstract class AdminPaymentsState extends Equatable {
  const AdminPaymentsState();

  @override
  List<Object?> get props => [];
}

class AdminPaymentsInitial extends AdminPaymentsState {}

class AdminPaymentsLoading extends AdminPaymentsState {}

class AdminPaymentsLoaded extends AdminPaymentsState {
  final List<AdminPaymentTransactionEntity> paymentTransactions;
  final List<AdminLoyaltyTransactionEntity> loyaltyTransactions;
  final String? statusFilter;
  final String? methodFilter;
  final String? searchQuery;
  final bool hasReachedMaxPayments;
  final bool isLoadingMorePayments;
  final bool hasReachedMaxLoyalty;
  final bool isLoadingMoreLoyalty;

  const AdminPaymentsLoaded({
    required this.paymentTransactions,
    required this.loyaltyTransactions,
    this.statusFilter,
    this.methodFilter,
    this.searchQuery,
    this.hasReachedMaxPayments = false,
    this.isLoadingMorePayments = false,
    this.hasReachedMaxLoyalty = false,
    this.isLoadingMoreLoyalty = false,
  });

  AdminPaymentsLoaded copyWith({
    List<AdminPaymentTransactionEntity>? paymentTransactions,
    List<AdminLoyaltyTransactionEntity>? loyaltyTransactions,
    String? statusFilter,
    String? methodFilter,
    String? searchQuery,
    bool? hasReachedMaxPayments,
    bool? isLoadingMorePayments,
    bool? hasReachedMaxLoyalty,
    bool? isLoadingMoreLoyalty,
  }) {
    return AdminPaymentsLoaded(
      paymentTransactions: paymentTransactions ?? this.paymentTransactions,
      loyaltyTransactions: loyaltyTransactions ?? this.loyaltyTransactions,
      statusFilter: statusFilter ?? this.statusFilter,
      methodFilter: methodFilter ?? this.methodFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      hasReachedMaxPayments: hasReachedMaxPayments ?? this.hasReachedMaxPayments,
      isLoadingMorePayments: isLoadingMorePayments ?? this.isLoadingMorePayments,
      hasReachedMaxLoyalty: hasReachedMaxLoyalty ?? this.hasReachedMaxLoyalty,
      isLoadingMoreLoyalty: isLoadingMoreLoyalty ?? this.isLoadingMoreLoyalty,
    );
  }

  @override
  List<Object?> get props => [
        paymentTransactions,
        loyaltyTransactions,
        statusFilter,
        methodFilter,
        searchQuery,
        hasReachedMaxPayments,
        isLoadingMorePayments,
        hasReachedMaxLoyalty,
        isLoadingMoreLoyalty,
      ];

  List<AdminPaymentTransactionEntity> get filteredPayments {
    return paymentTransactions.where((tx) {
      if (statusFilter != null && statusFilter!.isNotEmpty && statusFilter != 'all') {
        if (tx.status.toLowerCase() != statusFilter!.toLowerCase()) return false;
      }
      if (methodFilter != null && methodFilter!.isNotEmpty && methodFilter != 'all') {
        if (!tx.paymentMethod.toLowerCase().contains(methodFilter!.toLowerCase())) return false;
      }
      if (searchQuery != null && searchQuery!.isNotEmpty) {
        final q = searchQuery!.toLowerCase();
        final matchesOrder = tx.orderName.toLowerCase().contains(q);
        final matchesCustomer = tx.customerName.toLowerCase().contains(q);
        final matchesRef = tx.transactionReference?.toLowerCase().contains(q) ?? false;
        if (!matchesOrder && !matchesCustomer && !matchesRef) return false;
      }
      return true;
    }).toList();
  }
}

class AdminPaymentsError extends AdminPaymentsState {
  final String message;

  const AdminPaymentsError(this.message);

  @override
  List<Object?> get props => [message];
}

@injectable
class AdminPaymentsCubit extends Cubit<AdminPaymentsState> {
  final AdminRepository repository;

  AdminPaymentsCubit(this.repository) : super(AdminPaymentsInitial());

  Future<void> loadPaymentsData() async {
    emit(AdminPaymentsLoading());
    final paymentsRes = await repository.getPaymentTransactions(limit: 20, offset: 0);
    final loyaltyRes = await repository.getLoyaltyTransactions(limit: 20, offset: 0);

    paymentsRes.fold(
      (failure) => emit(AdminPaymentsError(failure.error.message)),
      (payments) {
        final loyaltyList = loyaltyRes.fold((_) => <AdminLoyaltyTransactionEntity>[], (r) => r);
        emit(AdminPaymentsLoaded(
          paymentTransactions: payments,
          loyaltyTransactions: loyaltyList,
          hasReachedMaxPayments: payments.length < 20,
          hasReachedMaxLoyalty: loyaltyList.length < 20,
        ));
      },
    );
  }

  Future<void> loadMorePayments() async {
    if (state is! AdminPaymentsLoaded) return;
    final cur = state as AdminPaymentsLoaded;
    if (cur.hasReachedMaxPayments || cur.isLoadingMorePayments) return;

    emit(cur.copyWith(isLoadingMorePayments: true));
    final res = await repository.getPaymentTransactions(
      limit: 20,
      offset: cur.paymentTransactions.length,
    );

    res.fold(
      (failure) => emit(cur.copyWith(isLoadingMorePayments: false)),
      (newPayments) {
        if (newPayments.isEmpty) {
          emit(cur.copyWith(
            isLoadingMorePayments: false,
            hasReachedMaxPayments: true,
          ));
        } else {
          final existingIds = cur.paymentTransactions.map((p) => p.id).toSet();
          final unique = newPayments.where((p) => !existingIds.contains(p.id)).toList();
          emit(cur.copyWith(
            paymentTransactions: [...cur.paymentTransactions, ...unique],
            isLoadingMorePayments: false,
            hasReachedMaxPayments: newPayments.length < 20,
          ));
        }
      },
    );
  }

  Future<void> loadMoreLoyalty() async {
    if (state is! AdminPaymentsLoaded) return;
    final cur = state as AdminPaymentsLoaded;
    if (cur.hasReachedMaxLoyalty || cur.isLoadingMoreLoyalty) return;

    emit(cur.copyWith(isLoadingMoreLoyalty: true));
    final res = await repository.getLoyaltyTransactions(
      limit: 20,
      offset: cur.loyaltyTransactions.length,
    );

    res.fold(
      (failure) => emit(cur.copyWith(isLoadingMoreLoyalty: false)),
      (newLoyalty) {
        if (newLoyalty.isEmpty) {
          emit(cur.copyWith(
            isLoadingMoreLoyalty: false,
            hasReachedMaxLoyalty: true,
          ));
        } else {
          final existingIds = cur.loyaltyTransactions.map((l) => l.id).toSet();
          final unique = newLoyalty.where((l) => !existingIds.contains(l.id)).toList();
          emit(cur.copyWith(
            loyaltyTransactions: [...cur.loyaltyTransactions, ...unique],
            isLoadingMoreLoyalty: false,
            hasReachedMaxLoyalty: newLoyalty.length < 20,
          ));
        }
      },
    );
  }

  void filterStatus(String? status) {
    if (state is AdminPaymentsLoaded) {
      final cur = state as AdminPaymentsLoaded;
      emit(AdminPaymentsLoaded(
        paymentTransactions: cur.paymentTransactions,
        loyaltyTransactions: cur.loyaltyTransactions,
        statusFilter: status,
        methodFilter: cur.methodFilter,
        searchQuery: cur.searchQuery,
      ));
    }
  }

  void filterMethod(String? method) {
    if (state is AdminPaymentsLoaded) {
      final cur = state as AdminPaymentsLoaded;
      emit(AdminPaymentsLoaded(
        paymentTransactions: cur.paymentTransactions,
        loyaltyTransactions: cur.loyaltyTransactions,
        statusFilter: cur.statusFilter,
        methodFilter: method,
        searchQuery: cur.searchQuery,
      ));
    }
  }

  void search(String query) {
    if (state is AdminPaymentsLoaded) {
      final cur = state as AdminPaymentsLoaded;
      emit(AdminPaymentsLoaded(
        paymentTransactions: cur.paymentTransactions,
        loyaltyTransactions: cur.loyaltyTransactions,
        statusFilter: cur.statusFilter,
        methodFilter: cur.methodFilter,
        searchQuery: query,
      ));
    }
  }
}
