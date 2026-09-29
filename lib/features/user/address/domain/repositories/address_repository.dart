import 'package:dartz/dartz.dart';
import 'package:dhabayih_lmamlaka/core/error/failure.dart';
import '../entities/address_entity.dart';

/// Abstract repository interface for address CRUD operations.
abstract class AddressRepository {
  /// Fetch all saved addresses for the current user.
  Future<Either<Failure, List<AddressEntity>>> getAddresses();

  /// Create a new address and return the created entity.
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
  });

  /// Update an existing address and return the updated entity.
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
  });

  /// Delete an address by ID.
  Future<Either<Failure, void>> deleteAddress(int id);

  /// Set an address as the default delivery address.
  Future<Either<Failure, void>> setDefaultAddress(int id);
}
