import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:dhabayih_lmamlaka/core/error/exceptions.dart';
import 'package:dhabayih_lmamlaka/core/error/failure.dart';
import 'package:dhabayih_lmamlaka/features/user/home/domain/entities/home_data.dart';
import '../../domain/repositories/highlight_repository.dart';
import '../datasources/highlight_remote_data_source.dart';

@LazySingleton(as: HighlightRepository)
class HighlightRepositoryImpl implements HighlightRepository {
  final HighlightRemoteDataSource remoteDataSource;

  HighlightRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<HighlightEntity>>> getMyHighlights(
    int userId,
  ) async {
    try {
      final models = await remoteDataSource.getMyHighlights(userId);
      return Right(models.map((m) => m.toDomain()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorMessageModel));
    }
  }

  @override
  Future<Either<Failure, HighlightEntity>> createHighlight({
    required String filePath,
    required String mediaType,
    String? name,
  }) async {
    try {
      final model = await remoteDataSource.createHighlight(
        filePath: filePath,
        mediaType: mediaType,
        name: name,
      );
      return Right(model.toDomain());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorMessageModel));
    }
  }

  @override
  Future<Either<Failure, void>> deleteHighlight(int highlightId) async {
    try {
      await remoteDataSource.deleteHighlight(highlightId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorMessageModel));
    }
  }
}
