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
  static const String _categoriesCacheTimeKey = 'cached_catalog_categories_time_v1';
  static const Duration _cacheTtl = Duration(hours: 24);

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
          // Persist categories and timestamp in background with 24h TTL
          try {
            await prefs.setString(_categoriesCacheKey, jsonEncode(categoriesList));
            await prefs.setInt(_categoriesCacheTimeKey, DateTime.now().millisecondsSinceEpoch);
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
      // Offline / network fallback: check cache and TTL
      final cachedJson = prefs.getString(_categoriesCacheKey);
      final cacheTimestamp = prefs.getInt(_categoriesCacheTimeKey);
      final isExpired = cacheTimestamp != null &&
          DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(cacheTimestamp)) > _cacheTtl;

      if (cachedJson != null && cachedJson.isNotEmpty && !isExpired) {
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
