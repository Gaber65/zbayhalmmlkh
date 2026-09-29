import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../user/orders/domain/entities/branch_entity.dart';
import '../../domain/repositories/admin_repository.dart';

abstract class AdminBranchesState extends Equatable {
  const AdminBranchesState();

  @override
  List<Object?> get props => [];
}

class AdminBranchesInitial extends AdminBranchesState {}

class AdminBranchesLoading extends AdminBranchesState {}

class AdminBranchesLoaded extends AdminBranchesState {
  final List<BranchEntity> branches;
  final bool isSubmitting;
  final String? successMessage;

  const AdminBranchesLoaded({
    required this.branches,
    this.isSubmitting = false,
    this.successMessage,
  });

  AdminBranchesLoaded copyWith({
    List<BranchEntity>? branches,
    bool? isSubmitting,
    String? successMessage,
  }) {
    return AdminBranchesLoaded(
      branches: branches ?? this.branches,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [branches, isSubmitting, successMessage];
}

class AdminBranchesError extends AdminBranchesState {
  final String message;

  const AdminBranchesError(this.message);

  @override
  List<Object?> get props => [message];
}

@injectable
class AdminBranchesCubit extends Cubit<AdminBranchesState> {
  final AdminRepository repository;

  AdminBranchesCubit(this.repository) : super(AdminBranchesInitial());

  Future<void> loadBranches({bool silent = false}) async {
    if (!silent) emit(AdminBranchesLoading());

    final result = await repository.getAdminBranches(includeInactive: true);
    result.fold(
      (failure) => emit(AdminBranchesError(failure.error.message)),
      (branches) => emit(AdminBranchesLoaded(branches: branches)),
    );
  }

  Future<bool> createBranch(Map<String, dynamic> data) async {
    final current = state;
    if (current is AdminBranchesLoaded) {
      emit(current.copyWith(isSubmitting: true));
    }

    final result = await repository.createBranch(data);
    return result.fold(
      (failure) {
        if (state is AdminBranchesLoaded) {
          emit((state as AdminBranchesLoaded).copyWith(isSubmitting: false));
        }
        return false;
      },
      (newBranch) {
        loadBranches(silent: true);
        return true;
      },
    );
  }

  Future<bool> updateBranch(int id, Map<String, dynamic> data) async {
    final current = state;
    if (current is AdminBranchesLoaded) {
      emit(current.copyWith(isSubmitting: true));
    }

    final result = await repository.updateBranch(id, data);
    return result.fold(
      (failure) {
        if (state is AdminBranchesLoaded) {
          emit((state as AdminBranchesLoaded).copyWith(isSubmitting: false));
        }
        return false;
      },
      (updated) {
        loadBranches(silent: true);
        return true;
      },
    );
  }

  Future<bool> deleteBranch(int id) async {
    final current = state;
    if (current is AdminBranchesLoaded) {
      emit(current.copyWith(isSubmitting: true));
    }

    final result = await repository.deleteBranch(id);
    return result.fold(
      (failure) {
        if (state is AdminBranchesLoaded) {
          emit((state as AdminBranchesLoaded).copyWith(isSubmitting: false));
        }
        return false;
      },
      (_) {
        loadBranches(silent: true);
        return true;
      },
    );
  }
}
