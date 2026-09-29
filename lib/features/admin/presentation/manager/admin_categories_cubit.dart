import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../user/catalog/domain/entities/category.dart';
import '../../domain/repositories/admin_repository.dart';

abstract class AdminCategoriesState extends Equatable {
  const AdminCategoriesState();
  @override
  List<Object?> get props => [];
}

class AdminCategoriesInitial extends AdminCategoriesState {}

class AdminCategoriesLoading extends AdminCategoriesState {}

class AdminCategoriesLoaded extends AdminCategoriesState {
  final List<Category> categories;
  final bool isSubmitting;

  const AdminCategoriesLoaded({
    required this.categories,
    this.isSubmitting = false,
  });

  AdminCategoriesLoaded copyWith({
    List<Category>? categories,
    bool? isSubmitting,
  }) {
    return AdminCategoriesLoaded(
      categories: categories ?? this.categories,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [categories, isSubmitting];
}

class AdminCategoriesError extends AdminCategoriesState {
  final String message;
  const AdminCategoriesError({required this.message});
  @override
  List<Object?> get props => [message];
}

@injectable
class AdminCategoriesCubit extends Cubit<AdminCategoriesState> {
  final AdminRepository repository;

  AdminCategoriesCubit({required this.repository}) : super(AdminCategoriesInitial());

  Future<void> loadCategories({bool silent = false}) async {
    if (!silent) emit(AdminCategoriesLoading());

    final result = await repository.getAdminCategories();
    result.fold(
      (failure) => emit(AdminCategoriesError(message: failure.error.message)),
      (categories) => emit(AdminCategoriesLoaded(categories: categories)),
    );
  }

  Future<bool> createCategory(Map<String, dynamic> data) async {
    if (state is AdminCategoriesLoaded) {
      emit((state as AdminCategoriesLoaded).copyWith(isSubmitting: true));
    }

    final result = await repository.createCategory(data);
    return result.fold(
      (failure) {
        if (state is AdminCategoriesLoaded) {
          emit((state as AdminCategoriesLoaded).copyWith(isSubmitting: false));
        }
        return false;
      },
      (newCategory) {
        loadCategories(silent: true);
        return true;
      },
    );
  }

  Future<bool> updateCategory(int id, Map<String, dynamic> data) async {
    if (state is AdminCategoriesLoaded) {
      emit((state as AdminCategoriesLoaded).copyWith(isSubmitting: true));
    }

    final result = await repository.updateCategory(id, data);
    return result.fold(
      (failure) {
        if (state is AdminCategoriesLoaded) {
          emit((state as AdminCategoriesLoaded).copyWith(isSubmitting: false));
        }
        return false;
      },
      (updated) {
        loadCategories(silent: true);
        return true;
      },
    );
  }

  Future<bool> deleteCategory(int id) async {
    final result = await repository.deleteCategory(id);
    return result.fold(
      (failure) => false,
      (_) {
        loadCategories(silent: true);
        return true;
      },
    );
  }
}
