import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:dhabayih_lmamlaka/core/error/exceptions.dart';
import 'package:dhabayih_lmamlaka/core/error/failure.dart';
import 'package:dhabayih_lmamlaka/core/network/error_message_model.dart';
import '../../domain/entities/address_entity.dart';
import '../../domain/repositories/address_repository.dart';
import '../datasources/address_remote_data_source.dart';

@LazySingleton(as: AddressRepository)
class AddressRepositoryImpl implements AddressRepository {
  final AddressRemoteDataSource remoteDataSource;

  AddressRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<AddressEntity>>> getAddresses() async {
    try {
      final models = await remoteDataSource.getAddresses();
      return Right(models.map((m) => m.toDomain()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorMessageModel));
    } catch (e) {
      return Left(ServerFailure(_unknownError(e)));
    }
  }

  @override
  Future<Either<Failure, AddressEntity>> createAddress({
    required String title,
    required String recipientName,
    required String recipientPhone,
    required int countryId,
    required String city,
    required String street,
    required String district,
    required String postalCode,
    required String fullAddress,
    required String buildingNumber,
    required String floor,
    required String apartment,
    required String landmark,
    required String notes,
    required double latitude,
    required double longitude,
    required bool isDefault,
  }) async {
    try {
      final body = {
        'title': title,
        'recipient_name': recipientName,
        'recipient_phone': recipientPhone,
        'country_id': countryId,
        'city': city,
        'street': street,
        'district': district,
        'postal_code': postalCode,
        'full_address': fullAddress,
        'building_number': buildingNumber,
        'floor': floor,
        'apartment': apartment,
        'landmark': landmark,
        'notes': notes,
        'latitude': latitude,
        'longitude': longitude,
        'is_default': isDefault,
      };
      final model = await remoteDataSource.createAddress(body);
      return Right(model.toDomain(
        district: district,
        postalCode: postalCode,
        fullAddress: fullAddress,
        buildingNumber: buildingNumber,
        floor: floor,
        apartment: apartment,
        landmark: landmark,
        notes: notes,
      ));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorMessageModel));
    } catch (e) {
      return Left(ServerFailure(_unknownError(e)));
    }
  }

  @override
  Future<Either<Failure, AddressEntity>> updateAddress({
    required int id,
    required String title,
    required String recipientName,
    required String recipientPhone,
    required int countryId,
    required String city,
    required String street,
    required String district,
    required String postalCode,
    required String fullAddress,
    required String buildingNumber,
    required String floor,
    required String apartment,
    required String landmark,
    required String notes,
    required double latitude,
    required double longitude,
    required bool isDefault,
  }) async {
    try {
      final body = {
        'title': title,
        'recipient_name': recipientName,
        'recipient_phone': recipientPhone,
        'country_id': countryId,
        'city': city,
        'street': street,
        'district': district,
        'postal_code': postalCode,
        'full_address': fullAddress,
        'building_number': buildingNumber,
        'floor': floor,
        'apartment': apartment,
        'landmark': landmark,
        'notes': notes,
        'latitude': latitude,
        'longitude': longitude,
        'is_default': isDefault,
      };
      final model = await remoteDataSource.updateAddress(id, body);
      return Right(model.toDomain(
        district: district,
        postalCode: postalCode,
        fullAddress: fullAddress,
        buildingNumber: buildingNumber,
        floor: floor,
        apartment: apartment,
        landmark: landmark,
        notes: notes,
      ));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorMessageModel));
    } catch (e) {
      return Left(ServerFailure(_unknownError(e)));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAddress(int id) async {
    try {
      await remoteDataSource.deleteAddress(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorMessageModel));
    } catch (e) {
      return Left(ServerFailure(_unknownError(e)));
    }
  }

  @override
  Future<Either<Failure, void>> setDefaultAddress(int id) async {
    try {
      await remoteDataSource.setDefaultAddress(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorMessageModel));
    } catch (e) {
      return Left(ServerFailure(_unknownError(e)));
    }
  }

  ErrorMessageModel _unknownError(Object e) => ErrorMessageModel(
        message: e.toString(),
        errors: [],
        success: false,
        statusCode: 500,
      );
}
