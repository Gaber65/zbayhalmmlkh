import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:dhabayih_lmamlaka/core/error/failure.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class LoginUseCase {
  final AuthRepository repository;
  LoginUseCase(this.repository);

  Future<Either<Failure, void>> call(String email) {
    return repository.login(email);
  }
}

@lazySingleton
class RegisterUseCase {
  final AuthRepository repository;
  RegisterUseCase(this.repository);

  Future<Either<Failure, void>> call(String email) {
    return repository.register(email);
  }
}

@lazySingleton
class VerifyLoginOtpUseCase {
  final AuthRepository repository;
  VerifyLoginOtpUseCase(this.repository);

  Future<Either<Failure, User>> call(String email, String otp) {
    return repository.verifyLoginOtp(email, otp);
  }
}

@lazySingleton
class VerifyRegisterOtpUseCase {
  final AuthRepository repository;
  VerifyRegisterOtpUseCase(this.repository);

  Future<Either<Failure, User>> call(String email, String otp) {
    return repository.verifyRegisterOtp(email, otp);
  }
}

@lazySingleton
class LogoutUseCase {
  final AuthRepository repository;
  LogoutUseCase(this.repository);

  Future<Either<Failure, void>> call() {
    return repository.logout();
  }
}

@lazySingleton
class GetCachedUserUseCase {
  final AuthRepository repository;
  GetCachedUserUseCase(this.repository);

  Future<Either<Failure, User?>> call() {
    return repository.getCachedUser();
  }
}
