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
    print('========== CACHE USER ==========');
    print('User Data: ${userToCache.toJson()}');

    if (userToCache.accessToken != null) {
      print('Saving Access Token...');
      await secureStorage.write(
        key: accessTokenKey,
        value: userToCache.accessToken!,
      );
    }

    if (userToCache.refreshToken != null) {
      print('Saving Refresh Token...');
      await secureStorage.write(
        key: refreshTokenKey,
        value: userToCache.refreshToken!,
      );
    }

    await sharedPreferences.setString(
      cachedUserKey,
      json.encode(userToCache.toJson()),
    );

    final storedAccess = await secureStorage.read(key: accessTokenKey);
    final storedRefresh = await secureStorage.read(key: refreshTokenKey);
    final cachedJson = sharedPreferences.getString(cachedUserKey);

    print('Stored Access Token: $storedAccess');
    print('Stored Refresh Token: $storedRefresh');
    print('Cached JSON: $cachedJson');
    print('========== CACHE USER DONE ==========');
  }

  @override
  Future<UserModel?> getCachedUser() async {
    print('========== GET CACHED USER ==========');

    final jsonString = sharedPreferences.getString(cachedUserKey);

    print('Cached JSON: $jsonString');

    if (jsonString != null) {
      final user = UserModel.fromJson(json.decode(jsonString));
      print('Parsed User: ${user.toJson()}');

      final storedAccess = await secureStorage.read(key: accessTokenKey);
      final storedRefresh = await secureStorage.read(key: refreshTokenKey);

      print('Access Token: $storedAccess');
      print('Refresh Token: $storedRefresh');

      print('========== USER FOUND ==========');
      return user;
    }

    print('No cached user found.');
    print('================================');

    return null;
  }

  @override
  Future<void> clearCache() async {
    print('========== CLEAR CACHE ==========');

    await sharedPreferences.remove(cachedUserKey);
    await secureStorage.delete(key: accessTokenKey);
    await secureStorage.delete(key: refreshTokenKey);

    print('Cache cleared successfully.');

    final access = await secureStorage.read(key: accessTokenKey);
    final refresh = await secureStorage.read(key: refreshTokenKey);
    final cached = sharedPreferences.getString(cachedUserKey);

    print('Access After Clear: $access');
    print('Refresh After Clear: $refresh');
    print('Cached User After Clear: $cached');

    print('========== CLEAR CACHE DONE ==========');
  }
}
