import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/api/server_strings.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/network/error_message_model.dart';
import '../../../catalog/data/models/product_model.dart';

abstract class SearchRemoteDataSource {
  Future<List<ProductModel>> searchProducts(String query);
  Future<List<String>> getPopularSearches();
}

@LazySingleton(as: SearchRemoteDataSource)
class SearchRemoteDataSourceImpl with DioErrorHandler implements SearchRemoteDataSource {
  final Dio dio;

  SearchRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<ProductModel>> searchProducts(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final response = await dio.get(
        ServerStrings.products,
        queryParameters: {'search': query.trim()},
      );
      if (response.statusCode == 200) {
        final dynamic responseData = response.data['data'] ?? response.data;
        final dynamic productsList = responseData is Map
            ? (responseData['data'] ?? responseData['products'])
            : responseData;
        if (productsList is List) {
          return productsList.map((e) => ProductModel.fromJson(e)).toList();
        }
        return [];
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
  Future<List<String>> getPopularSearches() async {
    return [];
  }
}

