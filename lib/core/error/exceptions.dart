import 'package:dio/dio.dart';
import '../network/error_message_model.dart';

class ServerException implements Exception {
  final ErrorMessageModel errorMessageModel;

  const ServerException({required this.errorMessageModel});
}

class LocalDatabaseException implements Exception {
  final String errorMessage;

  const LocalDatabaseException({required this.errorMessage});
}

mixin DioErrorHandler {
  ServerException handleDioError(DioException e) {
    if (e.response != null && e.response!.data != null) {
      return ServerException(
        errorMessageModel: ErrorMessageModel.fromJson(
          e.response!.data is Map<String, dynamic>
              ? e.response!.data as Map<String, dynamic>
              : {},
        ),
      );
    }
    return ServerException(
      errorMessageModel: ErrorMessageModel(
        message: e.message ?? 'Unknown error occurred',
        errors: const [],
        success: false,
        statusCode: e.response?.statusCode ?? 500,
      ),
    );
  }
}
