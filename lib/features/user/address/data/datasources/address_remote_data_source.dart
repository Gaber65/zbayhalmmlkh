import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:dhabayih_lmamlaka/core/api/server_strings.dart';
import 'package:dhabayih_lmamlaka/core/error/exceptions.dart';
import 'package:dhabayih_lmamlaka/core/network/error_message_model.dart';
import '../models/address_model.dart';

abstract class AddressRemoteDataSource {
  Future<List<AddressModel>> getAddresses();
  Future<AddressModel> createAddress(Map<String, dynamic> body);
  Future<AddressModel> updateAddress(int id, Map<String, dynamic> body);
  Future<void> deleteAddress(int id);
  Future<void> setDefaultAddress(int id);
}

@LazySingleton(as: AddressRemoteDataSource)
class AddressRemoteDataSourceImpl with DioErrorHandler implements AddressRemoteDataSource {
  final Dio dio;

  AddressRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<AddressModel>> getAddresses() async {
    try {
      final response = await dio.get(ServerStrings.addresses);
      if (response.statusCode == 200) {
        final dynamic data = response.data['data'] ?? response.data;
        if (data is List) {
          return data
              .map((e) => AddressModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return [];
      }
      throw _serverException(response.data);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<AddressModel> createAddress(Map<String, dynamic> body) async {
    try {
      final response = await dio.post(ServerStrings.addresses, data: body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final dynamic data = response.data['data'] ?? response.data;
        return AddressModel.fromJson(data as Map<String, dynamic>);
      }
      throw _serverException(response.data);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<AddressModel> updateAddress(int id, Map<String, dynamic> body) async {
    try {
      final response = await dio.put(ServerStrings.addressById(id), data: body);
      if (response.statusCode == 200) {
        final dynamic data = response.data['data'] ?? response.data;
        return AddressModel.fromJson(data as Map<String, dynamic>);
      }
      throw _serverException(response.data);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<void> deleteAddress(int id) async {
    try {
      final response = await dio.delete(ServerStrings.addressById(id));
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw _serverException(response.data);
      }
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<void> setDefaultAddress(int id) async {
    try {
      final response = await dio.post(ServerStrings.setDefaultAddress(id));
      if (response.statusCode != 200) {
        throw _serverException(response.data);
      }
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  ServerException _serverException(dynamic data) => ServerException(
        errorMessageModel: ErrorMessageModel.fromJson(
          data is Map<String, dynamic> ? data : {},
        ),
      );

}
