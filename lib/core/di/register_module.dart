import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';
import '../api/api_interceptors.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

@module
abstract class RegisterModule {
  @preResolve
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();

  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();

  @lazySingleton
  InternetConnectionChecker get connectionChecker => InternetConnectionChecker.createInstance();

  @lazySingleton
  Dio dio(SharedPreferences prefs, FlutterSecureStorage secureStorage) {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(LangInterceptor(prefs: prefs));
    dio.interceptors.add(
      AuthInterceptor(
        getToken: () async {
          final token = await secureStorage.read(key: 'access_token');
          if (token != null && token.isNotEmpty) return token;
          final cachedUserStr = prefs.getString('CACHED_USER');
          if (cachedUserStr != null) {
            try {
              final map = json.decode(cachedUserStr);
              return map['access_token'] as String?;
            } catch (_) {}
          }
          return null;
        },
        secureStorage: secureStorage,
        prefs: prefs,
      ),
    );
    dio.interceptors.add(ApiInterceptor());

    if (AppConfig.enableLogging) {
      dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
        ),
      );
    }

    return dio;
  }
}
