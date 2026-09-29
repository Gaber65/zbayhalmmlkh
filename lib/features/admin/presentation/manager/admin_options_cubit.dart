import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/admin_entities.dart';
import '../../domain/repositories/admin_repository.dart';

abstract class AdminOptionsState extends Equatable {
  const AdminOptionsState();
  @override
  List<Object?> get props => [];
}

class AdminOptionsInitial extends AdminOptionsState {}

class AdminOptionsLoading extends AdminOptionsState {}

class AdminOptionsLoaded extends AdminOptionsState {
  final List<AdminOptionEntity> options;
  final List<AdminSizeEntity> sizes;
  final String activeType;
  final bool isSubmitting;

  const AdminOptionsLoaded({
    required this.options,
    this.sizes = const [],
    this.activeType = 'cutting',
    this.isSubmitting = false,
  });

  List<AdminOptionEntity> get cuttingOptions =>
      options.where((o) => o.type == 'cutting').toList();

  List<AdminOptionEntity> get packagingOptions =>
      options.where((o) => o.type == 'packaging').toList();

  List<AdminOptionEntity> get excludedParts =>
      options.where((o) => o.type == 'excluded_part').toList();

  AdminOptionsLoaded copyWith({
    List<AdminOptionEntity>? options,
    List<AdminSizeEntity>? sizes,
    String? activeType,
    bool? isSubmitting,
  }) {
    return AdminOptionsLoaded(
      options: options ?? this.options,
      sizes: sizes ?? this.sizes,
      activeType: activeType ?? this.activeType,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [options, sizes, activeType, isSubmitting];
}

class AdminOptionsError extends AdminOptionsState {
  final String message;
  const AdminOptionsError({required this.message});
  @override
  List<Object?> get props => [message];
}

@injectable
class AdminOptionsCubit extends Cubit<AdminOptionsState> {
  final AdminRepository repository;

  AdminOptionsCubit({required this.repository}) : super(AdminOptionsInitial());

  String _currentType = 'cutting';

  Future<void> loadOptions({String? type, bool silent = false}) async {
    if (type != null) _currentType = type;
    if (!silent) emit(AdminOptionsLoading());

    final result = await repository.getAdminOptions();
    final sizesResult = await repository.getAdminSizes();
    final sizes = sizesResult.fold((_) => <AdminSizeEntity>[], (s) => s);

    result.fold(
      (failure) => emit(AdminOptionsError(message: failure.error.message)),
      (options) => emit(AdminOptionsLoaded(
        options: options,
        sizes: sizes,
        activeType: _currentType,
      )),
    );
  }

  void switchTab(String type) {
    _currentType = type;
    if (state is AdminOptionsLoaded) {
      emit((state as AdminOptionsLoaded).copyWith(activeType: type));
    }
  }

  Future<bool> saveOption(Map<String, dynamic> data) async {
    if (state is AdminOptionsLoaded) {
      emit((state as AdminOptionsLoaded).copyWith(isSubmitting: true));
    }

    final result = await repository.saveOption(data);
    return result.fold(
      (failure) {
        if (state is AdminOptionsLoaded) {
          emit((state as AdminOptionsLoaded).copyWith(isSubmitting: false));
        }
        return false;
      },
      (saved) {
        loadOptions(silent: true);
        return true;
      },
    );
  }

  Future<bool> deleteOption(int id, {String? type}) async {
    final result = await repository.deleteOption(id, type: type);
    return result.fold(
      (failure) => false,
      (_) {
        loadOptions(silent: true);
        return true;
      },
    );
  }

  Future<bool> saveSize(Map<String, dynamic> data) async {
    if (state is AdminOptionsLoaded) {
      emit((state as AdminOptionsLoaded).copyWith(isSubmitting: true));
    }

    final result = await repository.saveSize(data);
    return result.fold(
      (failure) {
        if (state is AdminOptionsLoaded) {
          emit((state as AdminOptionsLoaded).copyWith(isSubmitting: false));
        }
        return false;
      },
      (saved) {
        loadOptions(silent: true);
        return true;
      },
    );
  }

  Future<bool> deleteSize(int id) async {
    final result = await repository.deleteSize(id);
    return result.fold(
      (failure) => false,
      (_) {
        loadOptions(silent: true);
        return true;
      },
    );
  }

  Future<bool> toggleOptionStatus(AdminOptionEntity option) async {
    if (state is AdminOptionsLoaded) {
      final currentLoaded = state as AdminOptionsLoaded;
      final updatedList = currentLoaded.options.map((o) {
        if (o.id == option.id) {
          return o.copyWith(isActive: !o.isActive);
        }
        return o;
      }).toList();
      emit(currentLoaded.copyWith(options: updatedList));
    }

    final success = await saveOption({
      'id': option.id,
      'name': option.name,
      'description': option.description ?? '',
      'extra_price': option.extraPrice,
      'type': option.type,
      'is_active': !option.isActive,
    });

    if (!success) {
      // Revert if failed
      loadOptions(silent: true);
    }
    return success;
  }
}
