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
class ApiInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Log request details
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📤 REQUEST[${options.method}] => URL: ${options.baseUrl}${options.path}');
    print('Headers: ${options.headers}');
    print('Query Parameters: ${options.queryParameters}');
    print('Body: ${options.data}');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Log response details
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print(
      '📥 RESPONSE[${response.statusCode}] => URL: ${response.requestOptions.baseUrl}${response.requestOptions.path}',
    );
    print('Data: ${response.data}');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Log error details
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print(
      '❌ ERROR[${err.response?.statusCode}] => URL: ${err.requestOptions.baseUrl}${err.requestOptions.path}',
    );
    print('Message: ${err.message}');
    print('Response: ${err.response?.data}');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    super.onError(err, handler);
  }
}

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
    } catch (e) {
      print('⚠️ Error decoding token expiration: $e');
    }
    return false;
  }

  Future<String?> _getRefreshToken() async {
    try {
      final token = await secureStorage.read(key: 'refresh_token');
      if (token != null && token.isNotEmpty) return token;
    } catch (e) {
      print('⚠️ secureStorage read error for refresh_token: $e');
    }
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
      print('⏳ Waiting for in-flight token refresh before sending ${options.path}...');
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
    print('🔒 Session expired or unauthorized. Clearing credentials & redirecting to Login screen...');
    try {
      await secureStorage.delete(key: 'access_token');
      await secureStorage.delete(key: 'refresh_token');
      await prefs.remove('CACHED_USER');
    } catch (e) {
      print('⚠️ Failed to clear session data: $e');
    }

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

        if (!isAuthPage) {
          print('🚀 Redirecting to ${Routes.login} from $currentLoc');
          AppRouter.router.go(Routes.login);
        }
      } catch (e) {
        print('⚠️ Navigation to login failed: $e');
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

    if (err.response?.statusCode == 401 && !isAuthRoute) {
      print('🔄 401 Unauthorized received on $path, attempting token refresh...');

      // If a refresh is already in progress, await its result
      if (_refreshCompleter != null) {
        print('⏳ Refresh already in progress, awaiting result for $path...');
        final newAccessToken = await _refreshCompleter!.future;
        if (newAccessToken != null && newAccessToken.isNotEmpty) {
          print('🔁 Retrying original request $path with freshly acquired token...');
          return _retryRequest(err.requestOptions, newAccessToken, handler);
        } else {
          return super.onError(err, handler);
        }
      }

      _refreshCompleter = Completer<String?>();

      try {
        final refreshToken = await _getRefreshToken();

        if (refreshToken == null || refreshToken.isEmpty) {
          print('⚠️ No refresh token available in storage to renew session.');
          _refreshCompleter?.complete(null);
          _refreshCompleter = null;
          await _handleSessionExpired();
          return super.onError(err, handler);
        }

        if (_isJwtExpired(refreshToken)) {
          print('🔒 Refresh token is expired by timestamp. Clearing session credentials.');
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
            print('✅ Token refreshed successfully!');
            try {
              await secureStorage.write(
                key: 'access_token',
                value: newAccessToken,
              );
              await secureStorage.write(
                key: 'refresh_token',
                value: newRefreshToken,
              );
            } catch (e) {
              print('⚠️ Failed to write tokens to secure storage: $e');
            }

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
        print('❌ AuthInterceptor Refresh Token Failed: $e');
        if (e is DioException) {
          print('❌ Refresh Response status: ${e.response?.statusCode}');
          print('❌ Refresh Response data: ${e.response?.data}');
        }

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
