import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:dhabayih_lmamlaka/core/api/server_strings.dart';
import 'package:dhabayih_lmamlaka/core/error/exceptions.dart';
import 'package:dhabayih_lmamlaka/core/network/error_message_model.dart';
import '../models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfileModel> getProfile();
  Future<UserProfileModel> updateProfile({
    String? name,
    String? phone,
    String? preferredLanguage,
    String? preferredTheme,
    bool? pushNotificationsEnabled,
  });
}

@LazySingleton(as: ProfileRemoteDataSource)
class ProfileRemoteDataSourceImpl with DioErrorHandler implements ProfileRemoteDataSource {
  final Dio dio;

  ProfileRemoteDataSourceImpl({required this.dio});

  @override
  Future<UserProfileModel> getProfile() async {
    try {
      final response = await dio.get(ServerStrings.profile);
      if (response.statusCode == 200) {
        final dynamic responseData = response.data['data'] ?? response.data;
        return UserProfileModel.fromJson(responseData as Map<String, dynamic>);
      } else {
        throw ServerException(
          errorMessageModel: ErrorMessageModel.fromJson(response.data ?? {}),
        );
      }
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<UserProfileModel> updateProfile({
    String? name,
    String? phone,
    String? preferredLanguage,
    String? preferredTheme,
    bool? pushNotificationsEnabled,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (name != null) {
        data['name'] = name;
      }
      if (phone != null) {
        data['phone'] = phone;
      }
      if (preferredLanguage != null) {
        data['preferred_language'] = preferredLanguage;
      }
      if (preferredTheme != null) {
        data['preferred_theme'] = preferredTheme;
      }
      if (pushNotificationsEnabled != null) {
        data['push_notifications_enabled'] = pushNotificationsEnabled;
      }

      final response = await dio.put(ServerStrings.updateProfile, data: data);
      if (response.statusCode == 200) {
        final dynamic responseData = response.data['data'] ?? response.data;
        return UserProfileModel.fromJson(responseData as Map<String, dynamic>);
      } else {
        throw ServerException(
          errorMessageModel: ErrorMessageModel.fromJson(response.data ?? {}),
        );
      }
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }
}
