import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/auth_usecases.dart';
import 'auth_state.dart';

@injectable
class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final VerifyLoginOtpUseCase _verifyLoginOtpUseCase;
  final VerifyRegisterOtpUseCase _verifyRegisterOtpUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetCachedUserUseCase _getCachedUserUseCase;

  AuthCubit(
    this._loginUseCase,
    this._registerUseCase,
    this._verifyLoginOtpUseCase,
    this._verifyRegisterOtpUseCase,
    this._logoutUseCase,
    this._getCachedUserUseCase,
  ) : super(AuthInitial());

  Future<void> checkAuthStatus() async {
    emit(AuthLoading());
    final result = await _getCachedUserUseCase();
    result.fold(
      (failure) => emit(AuthUnauthenticated()),
      (user) {
        if (user != null) {
          emit(AuthAuthenticated(user));
        } else {
          emit(AuthUnauthenticated());
        }
      },
    );
  }

  Future<void> login(String email) async {
    emit(AuthLoading());
    final result = await _loginUseCase(email);
    result.fold(
      (failure) => emit(AuthError(failure.error.message)),
      (_) {
        emit(AuthOtpSent(email, isLogin: true));
      },
    );
  }

  Future<void> register(String email) async {
    emit(AuthLoading());
    final result = await _registerUseCase(email);
    result.fold(
      (failure) => emit(AuthError(failure.error.message)),
      (_) {
        emit(AuthOtpSent(email, isLogin: false));
      },
    );
  }

  Future<void> verifyOtp(String email, String otp, {required bool isLogin}) async {
    emit(AuthLoading());
    final result = isLogin
        ? await _verifyLoginOtpUseCase(email, otp)
        : await _verifyRegisterOtpUseCase(email, otp);

    result.fold(
      (failure) => emit(AuthError(failure.error.message)),
      (user) {
        checkAuthStatus(); // Check status to get cached user and route appropriately
      },
    );
  }

  Future<void> logout() async {
    emit(AuthLoading());
    await _logoutUseCase();
    emit(AuthUnauthenticated());
  }
}
