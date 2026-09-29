import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/repositories/profile_repository.dart';
import 'profile_state.dart';

@injectable
class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository repository;

  ProfileCubit({required this.repository}) : super(ProfileInitial());

  Future<void> fetchProfile() async {
    emit(ProfileLoading());
    final result = await repository.getProfile();
    result.fold(
      (failure) => emit(ProfileError(failure.error.message)),
      (profile) => emit(ProfileLoaded(profile: profile)),
    );
  }

  Future<void> updateProfile({
    String? name,
    String? phone,
    String? preferredLanguage,
    String? preferredTheme,
    bool? pushNotificationsEnabled,
  }) async {
    final result = await repository.updateProfile(
      name: name,
      phone: phone,
      preferredLanguage: preferredLanguage,
      preferredTheme: preferredTheme,
      pushNotificationsEnabled: pushNotificationsEnabled,
    );
    result.fold(
      (failure) => emit(ProfileError(failure.error.message)),
      (profile) => emit(ProfileLoaded(profile: profile)),
    );
  }
}
