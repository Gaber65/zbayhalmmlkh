import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:dhabayih_lmamlaka/core/error/exceptions.dart';
import 'package:dhabayih_lmamlaka/core/error/failure.dart';
import 'package:dhabayih_lmamlaka/core/network/error_message_model.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';

@LazySingleton(as: ProfileRepository)
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserProfile>> getProfile() async {
    try {
      final model = await remoteDataSource.getProfile();
      return Right(model.toDomain());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorMessageModel));
    } catch (e) {
      return Left(ServerFailure(ErrorMessageModel(message: e.toString(), errors: [], success: false, statusCode: 500)));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> updateProfile({
    String? name,
    String? phone,
    String? preferredLanguage,
    String? preferredTheme,
    bool? pushNotificationsEnabled,
  }) async {
    try {
      final model = await remoteDataSource.updateProfile(
        name: name,
        phone: phone,
        preferredLanguage: preferredLanguage,
        preferredTheme: preferredTheme,
        pushNotificationsEnabled: pushNotificationsEnabled,
      );
      return Right(model.toDomain());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorMessageModel));
    } catch (e) {
      return Left(ServerFailure(ErrorMessageModel(message: e.toString(), errors: [], success: false, statusCode: 500)));
    }
  }
}
