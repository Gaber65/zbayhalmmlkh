import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:dhabayih_lmamlaka/core/api/server_strings.dart';
import 'package:dhabayih_lmamlaka/core/error/exceptions.dart';
import 'package:dhabayih_lmamlaka/core/network/error_message_model.dart';
import '../models/highlight_model.dart';

abstract class HighlightRemoteDataSource {
  Future<List<HighlightModel>> getMyHighlights(int userId);
  Future<HighlightModel> createHighlight({
    required String filePath,
    required String mediaType,
    String? name,
  });
  Future<void> deleteHighlight(int highlightId);
}

@LazySingleton(as: HighlightRemoteDataSource)
class HighlightRemoteDataSourceImpl
    with DioErrorHandler
    implements HighlightRemoteDataSource {
  final Dio dio;

  HighlightRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<HighlightModel>> getMyHighlights(int userId) async {
    try {
      final response = await dio.get(ServerStrings.highlightById(userId));
      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data is List) {
          return data
              .map((e) => HighlightModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return [];
      }
      throw ServerException(
        errorMessageModel: ErrorMessageModel.fromJson(response.data ?? {}),
      );
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<HighlightModel> createHighlight({
    required String filePath,
    required String mediaType,
    String? name,
  }) async {
    try {
      final formData = FormData.fromMap({
        'media_type': mediaType,
        if (name != null && name.isNotEmpty) 'name': name,
        'media': await MultipartFile.fromFile(
          filePath,
          filename: filePath.split('/').last,
        ),
      });

      final response = await dio.post(
        ServerStrings.highlights,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'];
        return HighlightModel.fromJson(data as Map<String, dynamic>);
      }
      throw ServerException(
        errorMessageModel: ErrorMessageModel.fromJson(response.data ?? {}),
      );
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<void> deleteHighlight(int highlightId) async {
    try {
      final response = await dio.delete(
        ServerStrings.highlightById(highlightId),
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException(
          errorMessageModel: ErrorMessageModel.fromJson(response.data ?? {}),
        );
      }
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }
}
