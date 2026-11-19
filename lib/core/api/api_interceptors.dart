import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../routes/app_router.dart';
import '../routes/routes.dart';
import '../../features/shared/auth/presentation/manager/auth_cubit.dart';

/// API Interceptor for handling requests, responses, and errors
/// Provides centralized logging and error handling
/// Standard API Interceptor
class ApiInterceptor extends Interceptor {}

/// Authentication Interceptor
/// Automatically adds authentication token to requests and refreshes expired tokens
class AuthInterceptor extends Interceptor {
  final Future<String?> Function() getToken;
  final FlutterSecureStorage secureStorage;
  final SharedPreferences prefs;

  AuthInterceptor({
    required this.getToken,
    required this.secureStorage,
    required this.prefs,
  });

  Completer<String?>? _refreshCompleter;

  bool _isJwtExpired(String? token) {
    if (token == null || token.isEmpty) return true;
    try {
      final parts = token.split('.');
      if (parts.length != 3) return false;
      final normalized = base64Url.normalize(parts[1]);
      final payloadString = utf8.decode(base64Url.decode(normalized));
      final payload = json.decode(payloadString);
      if (payload is Map && payload.containsKey('exp')) {
        final dynamic exp = payload['exp'];
        final int expSeconds =
            (exp is int) ? exp : int.tryParse(exp.toString()) ?? 0;
        if (expSeconds > 0) {
          final expiryDate = DateTime.fromMillisecondsSinceEpoch(
            expSeconds * 1000,
            isUtc: true,
          );
          return DateTime.now().toUtc().isAfter(expiryDate);
        }
      }
    } catch (_) {}
    return false;
  }

  Future<String?> _getRefreshToken() async {
    try {
      final token = await secureStorage.read(key: 'refresh_token');
      if (token != null && token.isNotEmpty) return token;
    } catch (_) {}
    final cachedUserStr = prefs.getString('CACHED_USER');
    if (cachedUserStr != null) {
      try {
        final Map<String, dynamic> userMap = json.decode(cachedUserStr);
        final token =
            (userMap['refresh_token'] ?? userMap['refreshToken']) as String?;
        if (token != null && token.isNotEmpty) return token;
      } catch (_) {}
    }
    return null;
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // If a refresh is currently running, wait for it before proceeding
    if (_refreshCompleter != null && !_refreshCompleter!.isCompleted) {
      final newToken = await _refreshCompleter!.future;
      if (newToken != null && newToken.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $newToken';
        return super.onRequest(options, handler);
      }
    }

    final token = await getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }

  Future<void> _handleSessionExpired() async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      // User is already a guest / unauthenticated. Do not redirect.
      return;
    }

    try {
      await secureStorage.delete(key: 'access_token');
      await secureStorage.delete(key: 'refresh_token');
      await prefs.remove('CACHED_USER');
    } catch (_) {}

    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final ctx = AppRouter.rootNavigatorKey.currentContext;
        if (ctx != null) {
          try {
            ctx.read<AuthCubit>().checkAuthStatus();
          } catch (_) {}
        }

        final currentLoc =
            AppRouter.router.routerDelegate.currentConfiguration.uri.toString();
        final isAuthPage = currentLoc == Routes.login ||
            currentLoc == Routes.register ||
            currentLoc == Routes.otp ||
            currentLoc == Routes.splash ||
            currentLoc == Routes.onboarding;

        // Never aggressively force redirect from main browsing screens (Home, Categories, Cart, Orders, Profile).
        // Let them gracefully display their built-in GuestPromptWidget without looping!
        final isMainBrowsingPage = currentLoc == Routes.home ||
            currentLoc == Routes.categories ||
            currentLoc == Routes.cart ||
            currentLoc == Routes.orders ||
            currentLoc == Routes.profile;

        if (!isAuthPage && !isMainBrowsingPage) {
          AppRouter.router.go(Routes.login);
        }
      } catch (e) {
        try {
          AppRouter.router.go(Routes.login);
        } catch (_) {}
      }
    });
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final path = err.requestOptions.path;
    final isAuthRoute = path.contains('/auth/refresh') ||
        path.contains('/auth/login') ||
        path.contains('/auth/register');

    final authHeader = err.requestOptions.headers['Authorization'] as String?;
    final hadBearerToken = authHeader != null &&
        authHeader.trim().isNotEmpty &&
        authHeader.trim().startsWith('Bearer ') &&
        authHeader.trim().length > 7 &&
        authHeader.trim() != 'Bearer null';

    if (err.response?.statusCode == 401 && !isAuthRoute && hadBearerToken) {
      // If a refresh is already in progress, await its result
      if (_refreshCompleter != null) {
        final newAccessToken = await _refreshCompleter!.future;
        if (newAccessToken != null && newAccessToken.isNotEmpty) {
          return _retryRequest(err.requestOptions, newAccessToken, handler);
        } else {
          return super.onError(err, handler);
        }
      }

      _refreshCompleter = Completer<String?>();

      try {
        final refreshToken = await _getRefreshToken();

        if (refreshToken == null || refreshToken.isEmpty) {
          _refreshCompleter?.complete(null);
          _refreshCompleter = null;
          await _handleSessionExpired();
          return super.onError(err, handler);
        }

        if (_isJwtExpired(refreshToken)) {
          _refreshCompleter?.complete(null);
          _refreshCompleter = null;
          await _handleSessionExpired();
          return super.onError(err, handler);
        }

        final baseUrl = err.requestOptions.baseUrl.isNotEmpty
            ? err.requestOptions.baseUrl
            : AppConfig.baseUrl;

        final refreshDio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $refreshToken',
            },
          ),
        );

        final response = await refreshDio.post(
          '/api/v1/auth/refresh',
          data: {'refresh_token': refreshToken},
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          final resData = response.data;
          final Map<String, dynamic> data = (resData is Map<String, dynamic>)
              ? (resData['data'] is Map<String, dynamic>
                  ? resData['data'] as Map<String, dynamic>
                  : resData)
              : <String, dynamic>{};

          final newAccessToken =
              (data['access_token'] ?? data['token'] ?? data['accessToken'])
                  ?.toString();
          final newRefreshToken =
              (data['refresh_token'] ?? data['refreshToken'])?.toString() ??
                  refreshToken;

          if (newAccessToken != null && newAccessToken.isNotEmpty) {
            try {
              await secureStorage.write(
                key: 'access_token',
                value: newAccessToken,
              );
              await secureStorage.write(
                key: 'refresh_token',
                value: newRefreshToken,
              );
            } catch (_) {}

            final cachedUserStr = prefs.getString('CACHED_USER');
            if (cachedUserStr != null) {
              try {
                final Map<String, dynamic> userMap = json.decode(cachedUserStr);
                userMap['access_token'] = newAccessToken;
                userMap['refresh_token'] = newRefreshToken;
                await prefs.setString('CACHED_USER', json.encode(userMap));
              } catch (_) {}
            }

            final completer = _refreshCompleter;
            _refreshCompleter = null;
            completer?.complete(newAccessToken);

            return _retryRequest(err.requestOptions, newAccessToken, handler);
          }
        }

        throw Exception(
          'Access token missing in refresh response: ${response.data}',
        );
      } catch (e) {
        final completer = _refreshCompleter;
        _refreshCompleter = null;
        completer?.complete(null);

        // When refresh fails (server rejected refresh token, 401/403 or invalid response)
        await _handleSessionExpired();
      }
    }
    super.onError(err, handler);

  }

  Future<void> _retryRequest(
    RequestOptions requestOptions,
    String newAccessToken,
    ErrorInterceptorHandler handler,
  ) async {
    try {
      requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
      final retryDio = Dio(
        BaseOptions(
          baseUrl: requestOptions.baseUrl,
          connectTimeout: requestOptions.connectTimeout,
          receiveTimeout: requestOptions.receiveTimeout,
          headers: Map<String, dynamic>.from(requestOptions.headers),
        ),
      );

      dynamic reqData = requestOptions.data;
      if (reqData is FormData) {
        reqData = reqData.clone();
      }

      final retryResponse = await retryDio.request(
        requestOptions.path,
        data: reqData,
        queryParameters: requestOptions.queryParameters,
        options: Options(
          method: requestOptions.method,
          contentType: requestOptions.contentType,
          headers: requestOptions.headers,
        ),
      );

      return handler.resolve(retryResponse);
    } catch (e) {
      if (e is DioException) {
        return handler.next(e);
      }
      return handler.reject(
        DioException(
          requestOptions: requestOptions,
          error: e,
        ),
      );
    }
  }
}

/// Language Interceptor
/// Automatically adds language headers to requests
class LangInterceptor extends Interceptor {
  final SharedPreferences prefs;

  LangInterceptor({required this.prefs});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final lang = prefs.getString('app_language_code') ?? 'ar';
    options.headers['Accept-Language'] = lang;
    options.headers['lang'] = lang;
    super.onRequest(options, handler);
  }
}
