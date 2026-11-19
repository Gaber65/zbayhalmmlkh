import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel userToCache);
  Future<UserModel?> getCachedUser();
  Future<void> clearCache();
}

@LazySingleton(as: AuthLocalDataSource)
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;
  final FlutterSecureStorage secureStorage;

  static const String cachedUserKey = 'CACHED_USER';
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';

  AuthLocalDataSourceImpl({
    required this.sharedPreferences,
    required this.secureStorage,
  });

  @override
  Future<void> cacheUser(UserModel userToCache) async {
    if (userToCache.accessToken != null) {
      await secureStorage.write(
        key: accessTokenKey,
        value: userToCache.accessToken!,
      );
    }

    if (userToCache.refreshToken != null) {
      await secureStorage.write(
        key: refreshTokenKey,
        value: userToCache.refreshToken!,
      );
    }

    await sharedPreferences.setString(
      cachedUserKey,
      json.encode(userToCache.toJson()),
    );
  }

  @override
  Future<UserModel?> getCachedUser() async {
    final jsonString = sharedPreferences.getString(cachedUserKey);

    if (jsonString != null) {
      final user = UserModel.fromJson(json.decode(jsonString));
      return user;
    }

    return null;
  }

  @override
  Future<void> clearCache() async {
    await sharedPreferences.remove(cachedUserKey);
    await secureStorage.delete(key: accessTokenKey);
    await secureStorage.delete(key: refreshTokenKey);
  }
}
