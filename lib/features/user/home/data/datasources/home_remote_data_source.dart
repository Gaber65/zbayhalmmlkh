import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:dhabayih_lmamlaka/core/error/exceptions.dart';

import '../models/home_response_model.dart';

abstract class HomeRemoteDataSource {
  Future<HomeResponseModel> getHomeData();
}

@LazySingleton(as: HomeRemoteDataSource)
class HomeRemoteDataSourceImpl with DioErrorHandler implements HomeRemoteDataSource {
  final Dio dio;

  HomeRemoteDataSourceImpl({required this.dio});

  @override
  Future<HomeResponseModel> getHomeData() async {
    try {
      final response = await dio.get('/api/v1/home');
      return HomeResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }
}
