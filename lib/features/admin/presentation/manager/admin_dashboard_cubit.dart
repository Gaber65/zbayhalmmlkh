import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/admin_entities.dart';
import '../../domain/repositories/admin_repository.dart';

abstract class AdminDashboardState extends Equatable {
  const AdminDashboardState();
  @override
  List<Object?> get props => [];
}

class AdminDashboardInitial extends AdminDashboardState {}

class AdminDashboardLoading extends AdminDashboardState {}

class AdminDashboardLoaded extends AdminDashboardState {
  final AdminDashboardStats stats;
  const AdminDashboardLoaded({required this.stats});
  @override
  List<Object?> get props => [stats];
}

class AdminDashboardError extends AdminDashboardState {
  final String message;
  const AdminDashboardError({required this.message});
  @override
  List<Object?> get props => [message];
}

@injectable
class AdminDashboardCubit extends Cubit<AdminDashboardState> {
  final AdminRepository repository;

  AdminDashboardCubit({required this.repository}) : super(AdminDashboardInitial());

  Future<void> loadStats() async {
    emit(AdminDashboardLoading());
    final result = await repository.getDashboardStats();
    result.fold(
      (failure) => emit(AdminDashboardError(message: failure.error.message)),
      (stats) => emit(AdminDashboardLoaded(stats: stats)),
    );
  }
}
