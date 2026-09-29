import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:dhabayih_lmamlaka/core/error/failure.dart';
import '../entities/address_entity.dart';
import '../repositories/address_repository.dart';

// ─── GetAddressesUseCase ──────────────────────────────────────────────────────

@injectable
class GetAddressesUseCase {
  final AddressRepository repository;
  const GetAddressesUseCase(this.repository);

  Future<Either<Failure, List<AddressEntity>>> call() =>
      repository.getAddresses();
}

// ─── CreateAddressParams ──────────────────────────────────────────────────────

class AddressParams {
  final String title;
  final String recipientName;
  final String recipientPhone;
  final int countryId;
  final String city;
  final String street;
  final String district;
  final String postalCode;
  final String fullAddress;
  final String buildingNumber;
  final String floor;
  final String apartment;
  final String landmark;
  final String notes;
  final double latitude;
  final double longitude;
  final bool isDefault;

  const AddressParams({
    required this.title,
    required this.recipientName,
    required this.recipientPhone,
    required this.countryId,
    required this.city,
    required this.street,
    required this.district,
    required this.postalCode,
    required this.fullAddress,
    required this.buildingNumber,
    required this.floor,
    required this.apartment,
    required this.landmark,
    required this.notes,
    required this.latitude,
    required this.longitude,
    required this.isDefault,
  });
}

// ─── CreateAddressUseCase ─────────────────────────────────────────────────────

@injectable
class CreateAddressUseCase {
  final AddressRepository repository;
  const CreateAddressUseCase(this.repository);

  Future<Either<Failure, AddressEntity>> call(AddressParams params) =>
      repository.createAddress(
        title: params.title,
        recipientName: params.recipientName,
        recipientPhone: params.recipientPhone,
        countryId: params.countryId,
        city: params.city,
        street: params.street,
        district: params.district,
        postalCode: params.postalCode,
        fullAddress: params.fullAddress,
        buildingNumber: params.buildingNumber,
        floor: params.floor,
        apartment: params.apartment,
        landmark: params.landmark,
        notes: params.notes,
        latitude: params.latitude,
        longitude: params.longitude,
        isDefault: params.isDefault,
      );
}

// ─── UpdateAddressUseCase ─────────────────────────────────────────────────────

class UpdateAddressParams extends AddressParams {
  final int id;
  const UpdateAddressParams({
    required this.id,
    required super.title,
    required super.recipientName,
    required super.recipientPhone,
    required super.countryId,
    required super.city,
    required super.street,
    required super.district,
    required super.postalCode,
    required super.fullAddress,
    required super.buildingNumber,
    required super.floor,
    required super.apartment,
    required super.landmark,
    required super.notes,
    required super.latitude,
    required super.longitude,
    required super.isDefault,
  });
}

@injectable
class UpdateAddressUseCase {
  final AddressRepository repository;
  const UpdateAddressUseCase(this.repository);

  Future<Either<Failure, AddressEntity>> call(UpdateAddressParams params) =>
      repository.updateAddress(
        id: params.id,
        title: params.title,
        recipientName: params.recipientName,
        recipientPhone: params.recipientPhone,
        countryId: params.countryId,
        city: params.city,
        street: params.street,
        district: params.district,
        postalCode: params.postalCode,
        fullAddress: params.fullAddress,
        buildingNumber: params.buildingNumber,
        floor: params.floor,
        apartment: params.apartment,
        landmark: params.landmark,
        notes: params.notes,
        latitude: params.latitude,
        longitude: params.longitude,
        isDefault: params.isDefault,
      );
}

// ─── DeleteAddressUseCase ─────────────────────────────────────────────────────

@injectable
class DeleteAddressUseCase {
  final AddressRepository repository;
  const DeleteAddressUseCase(this.repository);

  Future<Either<Failure, void>> call(int id) => repository.deleteAddress(id);
}

// ─── SetDefaultAddressUseCase ─────────────────────────────────────────────────

@injectable
class SetDefaultAddressUseCase {
  final AddressRepository repository;
  const SetDefaultAddressUseCase(this.repository);

  Future<Either<Failure, void>> call(int id) =>
      repository.setDefaultAddress(id);
}
