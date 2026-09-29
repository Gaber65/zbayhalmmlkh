import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/admin_entities.dart';
import '../../domain/repositories/admin_repository.dart';

abstract class AdminSettingsState extends Equatable {
  const AdminSettingsState();

  @override
  List<Object?> get props => [];
}

class AdminSettingsInitial extends AdminSettingsState {}

class AdminSettingsLoading extends AdminSettingsState {}

class AdminSettingsLoaded extends AdminSettingsState {
  final AdminLoyaltySettingsEntity loyaltySettings;
  final AdminContactSettingsEntity? contactSettings;
  final bool isSaving;
  final String? successMessage;

  const AdminSettingsLoaded({
    required this.loyaltySettings,
    this.contactSettings,
    this.isSaving = false,
    this.successMessage,
  });

  AdminSettingsLoaded copyWith({
    AdminLoyaltySettingsEntity? loyaltySettings,
    AdminContactSettingsEntity? contactSettings,
    bool? isSaving,
    String? successMessage,
  }) {
    return AdminSettingsLoaded(
      loyaltySettings: loyaltySettings ?? this.loyaltySettings,
      contactSettings: contactSettings ?? this.contactSettings,
      isSaving: isSaving ?? this.isSaving,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [loyaltySettings, contactSettings, isSaving, successMessage];
}

class AdminSettingsError extends AdminSettingsState {
  final String message;

  const AdminSettingsError(this.message);

  @override
  List<Object?> get props => [message];
}

@injectable
class AdminSettingsCubit extends Cubit<AdminSettingsState> {
  final AdminRepository repository;

  AdminSettingsCubit(this.repository) : super(AdminSettingsInitial());

  Future<void> loadSettings() async {
    emit(AdminSettingsLoading());
    final loyaltyRes = await repository.getLoyaltySettings();
    final contactRes = await repository.getContactSettings();

    if (loyaltyRes.isLeft() && contactRes.isLeft()) {
      final msg = loyaltyRes.fold((f) => f.error.message, (_) => '');
      emit(AdminSettingsError(msg.isNotEmpty ? msg : 'فشل في استرجاع إعدادات المتجر'));
      return;
    }

    final loyalty = loyaltyRes.getOrElse(() => const AdminLoyaltySettingsEntity(
      earningRate: 1.0,
      redemptionRate: 100.0,
      minRedemption: 500,
    ));
    final contact = contactRes.getOrElse(() => const AdminContactSettingsEntity(
      whatsappNumber: '+966500000000',
      whatsappDefaultMessage: 'مرحباً، أود الاستفسار عن ذبائح المملكة',
      whatsappEnabled: true,
      supportPhone: '920000000',
    ));

    emit(AdminSettingsLoaded(
      loyaltySettings: loyalty,
      contactSettings: contact,
    ));
  }

  Future<void> updateLoyaltySettings({
    required double earningRate,
    required double redemptionRate,
    required int minRedemption,
  }) async {
    final current = state;
    if (current is AdminSettingsLoaded) {
      emit(current.copyWith(isSaving: true));
    }

    final result = await repository.updateLoyaltySettings(
      earningRate: earningRate,
      redemptionRate: redemptionRate,
      minRedemption: minRedemption,
    );

    result.fold(
      (failure) => emit(AdminSettingsError(failure.error.message)),
      (updated) {
        if (state is AdminSettingsLoaded) {
          final curr = state as AdminSettingsLoaded;
          emit(curr.copyWith(
            loyaltySettings: updated,
            isSaving: false,
            successMessage: 'تم حفظ إعدادات برنامج الولاء بنجاح',
          ));
        } else {
          loadSettings();
        }
      },
    );
  }

  Future<void> updateContactSettings({
    required String whatsappNumber,
    required String whatsappDefaultMessage,
    required bool whatsappEnabled,
    required String supportPhone,
  }) async {
    final current = state;
    if (current is AdminSettingsLoaded) {
      emit(current.copyWith(isSaving: true));
    }

    final result = await repository.updateContactSettings(
      whatsappNumber: whatsappNumber,
      whatsappDefaultMessage: whatsappDefaultMessage,
      whatsappEnabled: whatsappEnabled,
      supportPhone: supportPhone,
    );

    result.fold(
      (failure) => emit(AdminSettingsError(failure.error.message)),
      (updated) {
        if (state is AdminSettingsLoaded) {
          final curr = state as AdminSettingsLoaded;
          emit(curr.copyWith(
            contactSettings: updated,
            isSaving: false,
            successMessage: 'تم حفظ إعدادات التواصل وواتساب بنجاح',
          ));
        } else {
          loadSettings();
        }
      },
    );
  }
}
