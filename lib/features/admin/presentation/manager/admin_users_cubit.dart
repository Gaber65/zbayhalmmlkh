import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/admin_entities.dart';
import '../../domain/repositories/admin_repository.dart';

abstract class AdminUsersState extends Equatable {
  const AdminUsersState();

  @override
  List<Object?> get props => [];
}

class AdminUsersInitial extends AdminUsersState {}

class AdminUsersLoading extends AdminUsersState {}

class AdminUsersLoaded extends AdminUsersState {
  final List<AdminUserEntity> users;
  final String? activeStatusFilter;
  final String? activeTypeFilter;
  final String? searchQuery;
  final bool hasReachedMax;
  final bool isLoadingMore;

  const AdminUsersLoaded({
    required this.users,
    this.activeStatusFilter,
    this.activeTypeFilter,
    this.searchQuery,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
  });

  AdminUsersLoaded copyWith({
    List<AdminUserEntity>? users,
    String? activeStatusFilter,
    String? activeTypeFilter,
    String? searchQuery,
    bool? hasReachedMax,
    bool? isLoadingMore,
  }) {
    return AdminUsersLoaded(
      users: users ?? this.users,
      activeStatusFilter: activeStatusFilter ?? this.activeStatusFilter,
      activeTypeFilter: activeTypeFilter ?? this.activeTypeFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [
        users,
        activeStatusFilter,
        activeTypeFilter,
        searchQuery,
        hasReachedMax,
        isLoadingMore,
      ];

  List<AdminUserEntity> get filteredUsers {
    return users.where((u) {
      if (activeStatusFilter != null && activeStatusFilter!.isNotEmpty && activeStatusFilter != 'all') {
        if (u.status != activeStatusFilter) return false;
      }
      if (activeTypeFilter != null && activeTypeFilter!.isNotEmpty && activeTypeFilter != 'all') {
        if (u.userType != activeTypeFilter) return false;
      }
      if (searchQuery != null && searchQuery!.isNotEmpty) {
        final q = searchQuery!.toLowerCase();
        final matchesName = u.name.toLowerCase().contains(q);
        final matchesEmail = u.email.toLowerCase().contains(q);
        final matchesPhone = u.phone?.toLowerCase().contains(q) ?? false;
        if (!matchesName && !matchesEmail && !matchesPhone) return false;
      }
      return true;
    }).toList();
  }
}

class AdminUsersError extends AdminUsersState {
  final String message;

  const AdminUsersError(this.message);

  @override
  List<Object?> get props => [message];
}

@injectable
class AdminUsersCubit extends Cubit<AdminUsersState> {
  final AdminRepository repository;

  AdminUsersCubit(this.repository) : super(AdminUsersInitial());

  String? _status;
  String? _userType;
  String? _query;

  Future<void> loadUsers({
    String? status,
    String? userType,
    String? query,
    bool silent = false,
  }) async {
    if (status != null) _status = status;
    if (userType != null) _userType = userType;
    if (query != null) _query = query;

    if (!silent) emit(AdminUsersLoading());
    final result = await repository.getAdminUsers(
      status: _status,
      userType: _userType,
      query: _query,
      limit: 20,
      offset: 0,
    );

    result.fold(
      (failure) => emit(AdminUsersError(failure.error.message)),
      (users) => emit(AdminUsersLoaded(
        users: users,
        activeStatusFilter: _status,
        activeTypeFilter: _userType,
        searchQuery: _query,
        hasReachedMax: users.length < 20,
        isLoadingMore: false,
      )),
    );
  }

  Future<void> loadMoreUsers() async {
    if (state is! AdminUsersLoaded) return;
    final current = state as AdminUsersLoaded;
    if (current.hasReachedMax || current.isLoadingMore) return;

    emit(current.copyWith(isLoadingMore: true));

    final result = await repository.getAdminUsers(
      status: _status,
      userType: _userType,
      query: _query,
      limit: 20,
      offset: current.users.length,
    );

    result.fold(
      (failure) => emit(current.copyWith(isLoadingMore: false)),
      (newUsers) {
        if (newUsers.isEmpty) {
          emit(current.copyWith(
            isLoadingMore: false,
            hasReachedMax: true,
          ));
        } else {
          final existingIds = current.users.map((u) => u.id).toSet();
          final uniqueNew = newUsers.where((u) => !existingIds.contains(u.id)).toList();
          emit(current.copyWith(
            users: [...current.users, ...uniqueNew],
            isLoadingMore: false,
            hasReachedMax: newUsers.length < 20,
          ));
        }
      },
    );
  }

  Future<bool> updateUserStatus(int userId, String newStatus) async {
    final result = await repository.updateAdminUserStatus(userId, newStatus);
    return result.fold(
      (failure) => false,
      (updatedUser) {
        if (state is AdminUsersLoaded) {
          final currentUsers = (state as AdminUsersLoaded).users;
          final updatedList = currentUsers.map((u) => u.id == userId ? updatedUser : u).toList();
          emit(AdminUsersLoaded(
            users: updatedList,
            activeStatusFilter: (state as AdminUsersLoaded).activeStatusFilter,
            activeTypeFilter: (state as AdminUsersLoaded).activeTypeFilter,
            searchQuery: (state as AdminUsersLoaded).searchQuery,
          ));
        }
        return true;
      },
    );
  }

  Future<bool> toggleCustomerStatus(int userId, bool isActive) async {
    final newStatus = isActive ? 'active' : 'suspended';
    if (state is AdminUsersLoaded) {
      final current = (state as AdminUsersLoaded);
      final updatedList = current.users.map((u) {
        if (u.id == userId) {
          return u.copyWith(status: newStatus);
        }
        return u;
      }).toList();
      emit(AdminUsersLoaded(
        users: updatedList,
        activeStatusFilter: current.activeStatusFilter,
        activeTypeFilter: current.activeTypeFilter,
        searchQuery: current.searchQuery,
      ));
    }

    final success = await updateUserStatus(userId, newStatus);
    if (!success) {
      loadUsers(silent: true);
    }
    return success;
  }

  Future<bool> createCustomer(Map<String, dynamic> data) async {
    final result = await repository.createAdminUser(data);
    return result.fold(
      (failure) => false,
      (newUser) {
        if (state is AdminUsersLoaded) {
          final current = (state as AdminUsersLoaded);
          emit(AdminUsersLoaded(
            users: [newUser, ...current.users],
            activeStatusFilter: current.activeStatusFilter,
            activeTypeFilter: current.activeTypeFilter,
            searchQuery: current.searchQuery,
          ));
        } else {
          loadUsers(silent: true);
        }
        return true;
      },
    );
  }

  Future<bool> updateCustomer(int userId, Map<String, dynamic> data) async {
    final result = await repository.updateAdminUser(userId, data);
    return result.fold(
      (failure) => false,
      (updatedUser) {
        if (state is AdminUsersLoaded) {
          final current = (state as AdminUsersLoaded);
          final updatedList = current.users.map((u) => u.id == userId ? updatedUser : u).toList();
          emit(AdminUsersLoaded(
            users: updatedList,
            activeStatusFilter: current.activeStatusFilter,
            activeTypeFilter: current.activeTypeFilter,
            searchQuery: current.searchQuery,
          ));
        }
        return true;
      },
    );
  }

  Future<bool> deleteCustomer(int userId) async {
    final result = await repository.deleteAdminUser(userId);
    return result.fold(
      (failure) => false,
      (_) {
        if (state is AdminUsersLoaded) {
          final current = (state as AdminUsersLoaded);
          final updatedList = current.users.where((u) => u.id != userId).toList();
          emit(AdminUsersLoaded(
            users: updatedList,
            activeStatusFilter: current.activeStatusFilter,
            activeTypeFilter: current.activeTypeFilter,
            searchQuery: current.searchQuery,
          ));
        }
        return true;
      },
    );
  }

  Future<bool> adjustLoyaltyPoints({
    required int userId,
    required int pointsChange,
    required String reason,
  }) async {
    final result = await repository.adjustUserLoyaltyPoints(
      userId: userId,
      pointsChange: pointsChange,
      reason: reason,
    );
    return result.fold(
      (failure) => false,
      (success) {
        if (success) {
          loadUsers(silent: true);
        }
        return success;
      },
    );
  }
}
