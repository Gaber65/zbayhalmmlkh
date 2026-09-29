import 'package:dartz/dartz.dart';
import 'package:dhabayih_lmamlaka/core/error/failure.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, void>> login(String email);
  Future<Either<Failure, void>> register(String email);
  Future<Either<Failure, User>> verifyLoginOtp(String email, String otp);
  Future<Either<Failure, User>> verifyRegisterOtp(String email, String otp);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, User?>> getCachedUser();
  Future<Either<Failure, void>> registerFcmToken();
}
