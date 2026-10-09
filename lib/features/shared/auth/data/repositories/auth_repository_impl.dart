import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:injectable/injectable.dart';
import 'package:dhabayih_lmamlaka/core/error/exceptions.dart';
import 'package:dhabayih_lmamlaka/core/error/failure.dart';
import 'package:dhabayih_lmamlaka/core/network/error_message_model.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../datasources/auth_local_data_source.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  /// Automatically fetches the FCM token and registers the device with backend after successful OTP verification.
  Future<void> _registerFcmDeviceToken() async {
    try {
      if (!kIsWeb && Platform.isIOS) {
        final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        if (apnsToken == null) {
          debugPrint('Skipping FCM registration: APNS token not available on iOS');
          return;
        }
      }
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null && fcmToken.isNotEmpty) {
        final deviceType = kIsWeb
            ? 'web'
            : Platform.isAndroid
            ? 'android'
            : Platform.isIOS
            ? 'ios'
            : 'unknown';
        await remoteDataSource.registerDevice(
          fcmToken: fcmToken,
          deviceName: '$deviceType Device',
          deviceType: deviceType,
        );
      }
    } catch (e) {
      print('FCM Token registration error after OTP verification: $e');
    }
  }

  @override
  Future<Either<Failure, void>> login(String email) async {
    try {
      await remoteDataSource.login(email);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorMessageModel));
    }
  }

  @override
  Future<Either<Failure, void>> register(String email) async {
    try {
      await remoteDataSource.register(email);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorMessageModel));
    }
  }

  @override
  Future<Either<Failure, User>> verifyLoginOtp(String email, String otp) async {
    try {
      print('========== VERIFY LOGIN OTP ==========');
      print('Email: $email');
      print('OTP: $otp');

      final userModel = await remoteDataSource.verifyLoginOtp(email, otp);

      print('API Response: ${userModel.toJson()}');

      await localDataSource.cacheUser(userModel);

      print('User cached successfully.');

      await _registerFcmDeviceToken();

      print('FCM device registered.');

      return Right(userModel.toDomain());
    } on ServerException catch (e) {
      print('ServerException: ${e.errorMessageModel.message}');
      return Left(ServerFailure(e.errorMessageModel));
    } catch (e, s) {
      print('Exception: $e');
      print(s);

      return Left(
        ServerFailure(
          ErrorMessageModel(
            message: e.toString(),
            errors: [],
            success: false,
            statusCode: 500,
          ),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, User>> verifyRegisterOtp(
    String email,
    String otp,
  ) async {
    try {
      print('========== VERIFY REGISTER OTP ==========');
      print('Email: $email');
      print('OTP: $otp');

      final userModel = await remoteDataSource.verifyRegisterOtp(email, otp);

      print('API Response: ${userModel.toJson()}');

      await localDataSource.cacheUser(userModel);

      print('User cached successfully.');

      await _registerFcmDeviceToken();

      print('FCM device registered.');

      return Right(userModel.toDomain());
    } on ServerException catch (e) {
      print('ServerException: ${e.errorMessageModel.message}');
      return Left(ServerFailure(e.errorMessageModel));
    } catch (e, s) {
      print('Exception: $e');
      print(s);

      return Left(
        ServerFailure(
          ErrorMessageModel(
            message: e.toString(),
            errors: [],
            success: false,
            statusCode: 500,
          ),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDataSource.clearCache();
      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure(
          ErrorMessageModel(
            message: e.toString(),
            errors: [],
            success: false,
            statusCode: 500,
          ),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, User?>> getCachedUser() async {
    try {
      final userModel = await localDataSource.getCachedUser();
      return Right(userModel?.toDomain());
    } catch (e) {
      return Left(
        CacheFailure(
          ErrorMessageModel(
            message: e.toString(),
            errors: [],
            success: false,
            statusCode: 500,
          ),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> registerFcmToken() async {
    try {
      await _registerFcmDeviceToken();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorMessageModel));
    } catch (e) {
      return Left(
        ServerFailure(
          ErrorMessageModel(
            message: e.toString(),
            errors: [],
            success: false,
            statusCode: 500,
          ),
        ),
      );
    }
  }
}
