import 'dart:async';
import 'package:dio/dio.dart';

/// Interceptor to deduplicate in-flight identical GET requests.
/// Prevents multiple simultaneous calls to the same endpoint from spamming the server.
class DedupingInterceptor extends Interceptor {
  final Map<String, Completer<Response>> _inFlightRequests = {};

  String _generateKey(RequestOptions options) {
    return '${options.method}:${options.baseUrl}${options.path}:${options.queryParameters.toString()}';
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Only deduplicate safe idempotent GET requests
    if (options.method.toUpperCase() != 'GET') {
      return handler.next(options);
    }

    final key = _generateKey(options);

    if (_inFlightRequests.containsKey(key)) {
      try {
        final cachedResponse = await _inFlightRequests[key]!.future;
        // Return cloned response with original options
        return handler.resolve(
          Response(
            requestOptions: options,
            data: cachedResponse.data,
            headers: cachedResponse.headers,
            statusCode: cachedResponse.statusCode,
            statusMessage: cachedResponse.statusMessage,
            extra: cachedResponse.extra,
          ),
        );
      } catch (e) {
        if (e is DioException) {
          return handler.reject(e);
        }
        return handler.reject(
          DioException(
            requestOptions: options,
            error: e,
            type: DioExceptionType.unknown,
          ),
        );
      }
    }

    _inFlightRequests[key] = Completer<Response>();
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.requestOptions.method.toUpperCase() == 'GET') {
      final key = _generateKey(response.requestOptions);
      if (_inFlightRequests.containsKey(key)) {
        final completer = _inFlightRequests.remove(key);
        if (completer != null && !completer.isCompleted) {
          completer.complete(response);
        }
      }
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.requestOptions.method.toUpperCase() == 'GET') {
      final key = _generateKey(err.requestOptions);
      if (_inFlightRequests.containsKey(key)) {
        final completer = _inFlightRequests.remove(key);
        if (completer != null && !completer.isCompleted) {
          completer.completeError(err);
        }
      }
    }
    handler.next(err);
  }
}

