import '../../domain/entities/address_entity.dart';

/// Data model (DTO) for an address as returned by /api/v1/addresses.
class AddressModel {
  final int id;
  final String title;
  final String recipientName;
  final String recipientPhone;
  final int countryId;
  final String countryName;
  final String city;
  final String street;
  final double latitude;
  final double longitude;
  final bool isDefault;

  const AddressModel({
    required this.id,
    required this.title,
    required this.recipientName,
    required this.recipientPhone,
    required this.countryId,
    required this.countryName,
    required this.city,
    required this.street,
    required this.latitude,
    required this.longitude,
    required this.isDefault,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? 'Home',
      recipientName: json['recipient_name'] as String? ?? '',
      recipientPhone: json['recipient_phone'] as String? ?? '',
      countryId: (json['country_id'] as num?)?.toInt() ?? 1,
      countryName: json['country_name'] as String? ?? '',
      city: json['city'] as String? ?? '',
      street: json['street'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      isDefault: json['is_default'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson({
    String? district,
    String? postalCode,
    String? fullAddress,
    String? buildingNumber,
    String? floor,
    String? apartment,
    String? landmark,
    String? notes,
  }) {
    return {
      'title': title,
      'recipient_name': recipientName,
      'recipient_phone': recipientPhone,
      'country_id': countryId,
      'city': city,
      'street': street,
      'latitude': latitude,
      'longitude': longitude,
      'is_default': isDefault,
      'district': ?district,
      'postal_code': ?postalCode,
      'full_address': ?fullAddress,
      'building_number': ?buildingNumber,
      'floor': ?floor,
      'apartment': ?apartment,
      'landmark': ?landmark,
      'notes': ?notes,
    };
  }

  AddressEntity toDomain({
    String district = '',
    String postalCode = '',
    String fullAddress = '',
    String buildingNumber = '',
    String floor = '',
    String apartment = '',
    String landmark = '',
    String notes = '',
  }) {
    return AddressEntity(
      id: id,
      title: title,
      recipientName: recipientName,
      recipientPhone: recipientPhone,
      countryId: countryId,
      countryName: countryName,
      city: city,
      street: street,
      district: district,
      postalCode: postalCode,
      fullAddress: fullAddress.isNotEmpty ? fullAddress : '$city, $street',
      buildingNumber: buildingNumber,
      floor: floor,
      apartment: apartment,
      landmark: landmark,
      notes: notes,
      latitude: latitude,
      longitude: longitude,
      isDefault: isDefault,
    );
  }
}
