import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:dhabayih_lmamlaka/core/error/exceptions.dart';
import 'package:dhabayih_lmamlaka/core/error/failure.dart';
import 'package:dhabayih_lmamlaka/core/network/error_message_model.dart';
import '../../../catalog/domain/entities/product.dart';
import '../../domain/repositories/search_repository.dart';
import '../datasources/search_remote_data_source.dart';

@LazySingleton(as: SearchRepository)
class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource remoteDataSource;

  SearchRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Product>>> searchProducts(String query) async {
    try {
      final models = await remoteDataSource.searchProducts(query);
      return Right(models.map((e) => e.toDomain()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorMessageModel));
    } catch (e) {
      return Left(ServerFailure(ErrorMessageModel(message: e.toString(), errors: [], success: false, statusCode: 500)));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getPopularSearches() async {
    try {
      final searches = await remoteDataSource.getPopularSearches();
      return Right(searches);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorMessageModel));
    } catch (e) {
      return Left(ServerFailure(ErrorMessageModel(message: e.toString(), errors: [], success: false, statusCode: 500)));
    }
  }
}
