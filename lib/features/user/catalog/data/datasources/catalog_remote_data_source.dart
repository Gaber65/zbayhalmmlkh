import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dhabayih_lmamlaka/core/api/server_strings.dart';
import 'package:dhabayih_lmamlaka/core/error/exceptions.dart';
import '../../../../../core/network/error_message_model.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

abstract class CatalogRemoteDataSource {
  Future<List<CategoryModel>> getCategories();
  Future<List<ProductModel>> getProducts();
  Future<List<ProductModel>> getProductsByCategory(int categoryId);
  Future<ProductModel> getProductById(int productId);
}

@LazySingleton(as: CatalogRemoteDataSource)
class CatalogRemoteDataSourceImpl with DioErrorHandler implements CatalogRemoteDataSource {
  final Dio dio;
  final SharedPreferences prefs;

  static const String _categoriesCacheKey = 'cached_catalog_categories_v1';

  CatalogRemoteDataSourceImpl({
    required this.dio,
    required this.prefs,
  });

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await dio.get(ServerStrings.catalogCategories);
      if (response.statusCode == 200) {
        final dynamic responseData = response.data['data'] ?? response.data;
        final dynamic categoriesList = responseData is Map ? responseData['categories'] : responseData;
        if (categoriesList is List) {
          // Persist categories in background for instant cache-first load
          try {
            await prefs.setString(_categoriesCacheKey, jsonEncode(categoriesList));
          } catch (_) {}
          return categoriesList.map((e) => CategoryModel.fromJson(e)).toList();
        } else {
          throw ServerException(
            errorMessageModel: ErrorMessageModel.fromJson(response.data ?? {}),
          );
        }
      } else {
        throw ServerException(
          errorMessageModel: ErrorMessageModel.fromJson(response.data ?? {}),
        );
      }
    } on DioException catch (e) {
      // Offline / network fallback: return cached categories if available
      final cachedJson = prefs.getString(_categoriesCacheKey);
      if (cachedJson != null && cachedJson.isNotEmpty) {
        try {
          final decoded = jsonDecode(cachedJson);
          if (decoded is List) {
            return decoded.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>)).toList();
          }
        } catch (_) {}
      }
      throw handleDioError(e);
    }
  }

  @override
  Future<List<ProductModel>> getProducts() async {
    try {
      final response = await dio.get(ServerStrings.products);
      if (response.statusCode == 200) {
        final dynamic responseData = response.data['data'] ?? response.data;
        final dynamic productsList = responseData is Map ? responseData['products'] : responseData;
        if (productsList is List) {
          return productsList.map((e) => ProductModel.fromJson(e)).toList();
        } else {
          throw ServerException(
            errorMessageModel: ErrorMessageModel.fromJson(response.data ?? {}),
          );
        }
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
  Future<List<ProductModel>> getProductsByCategory(int categoryId) async {
    try {
      final response = await dio.get(ServerStrings.categoryProducts(categoryId));
      if (response.statusCode == 200) {
        final dynamic responseData = response.data['data'] ?? response.data;
        final dynamic productsList = responseData is Map ? responseData['products'] : responseData;
        if (productsList is List) {
          return productsList.map((e) => ProductModel.fromJson(e)).toList();
        } else {
          throw ServerException(
            errorMessageModel: ErrorMessageModel.fromJson(response.data ?? {}),
          );
        }
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
  Future<ProductModel> getProductById(int productId) async {
    try {
      final response = await dio.get(ServerStrings.productById(productId));
      if (response.statusCode == 200) {
        final dynamic data = response.data['data'] ?? response.data;
        final dynamic productData = data is Map && data.containsKey('product')
            ? data['product']
            : data;
        return ProductModel.fromJson(productData as Map<String, dynamic>);
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
