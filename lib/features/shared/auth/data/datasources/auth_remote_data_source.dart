import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:dhabayih_lmamlaka/core/api/server_strings.dart';
import 'package:dhabayih_lmamlaka/core/error/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<void> login(String email);
  Future<void> register(String email);
  Future<UserModel> verifyLoginOtp(String email, String otp);
  Future<UserModel> verifyRegisterOtp(String email, String otp);
  Future<void> registerDevice({
    required String fcmToken,
    required String deviceName,
    required String deviceType,
  });
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl with DioErrorHandler implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<void> login(String email) async {
    try {
      final isPhone = !email.contains('@');
      await dio.post(ServerStrings.login, data: {
        'email': email,
        'phone': email,
        'identifier': email,
        'channel': isPhone ? 'sms' : 'email',
      });
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<void> register(String email) async {
    try {
      final isPhone = !email.contains('@');
      await dio.post(ServerStrings.register, data: {
        'email': email,
        'phone': email,
        'identifier': email,
        'channel': isPhone ? 'sms' : 'email',
      });
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<UserModel> verifyLoginOtp(String email, String otp) async {
    try {
      final response = await dio.post(
        '/api/v1/auth/login/verify',
        data: {
          'email': email,
          'phone': email,
          'identifier': email,
          'otp': otp,
          'code': otp,
        },
      );
      return UserModel.fromJson(response.data['data'] ?? response.data);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<UserModel> verifyRegisterOtp(String email, String otp) async {
    try {
      final response = await dio.post(
        '/api/v1/auth/register/verify',
        data: {
          'email': email,
          'phone': email,
          'identifier': email,
          'otp': otp,
          'code': otp,
        },
      );
      return UserModel.fromJson(response.data['data'] ?? response.data);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<void> registerDevice({
    required String fcmToken,
    required String deviceName,
    required String deviceType,
  }) async {
    try {
      await dio.post(
        ServerStrings.registerDevice,
        data: {
          'fcm_token': fcmToken,
          'device_name': deviceName,
          'device_type': deviceType,
        },
      );
    } catch (e) {
      print('Failed to register device FCM token: $e');
    }
  }
}
