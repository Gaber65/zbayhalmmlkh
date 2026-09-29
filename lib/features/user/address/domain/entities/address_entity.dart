import 'package:equatable/equatable.dart';

/// Domain entity representing a saved delivery address.
class AddressEntity extends Equatable {
  final int id;
  final String title;
  final String recipientName;
  final String recipientPhone;
  final int countryId;
  final String countryName;
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

  const AddressEntity({
    required this.id,
    required this.title,
    required this.recipientName,
    required this.recipientPhone,
    required this.countryId,
    required this.countryName,
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

  /// Returns a compact single-line representation for display.
  String get shortDisplay {
    final parts = [city, street].where((e) => e.isNotEmpty).toList();
    return parts.isNotEmpty ? parts.join(', ') : fullAddress;
  }

  AddressEntity copyWith({
    int? id,
    String? title,
    String? recipientName,
    String? recipientPhone,
    int? countryId,
    String? countryName,
    String? city,
    String? street,
    String? district,
    String? postalCode,
    String? fullAddress,
    String? buildingNumber,
    String? floor,
    String? apartment,
    String? landmark,
    String? notes,
    double? latitude,
    double? longitude,
    bool? isDefault,
  }) {
    return AddressEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      recipientName: recipientName ?? this.recipientName,
      recipientPhone: recipientPhone ?? this.recipientPhone,
      countryId: countryId ?? this.countryId,
      countryName: countryName ?? this.countryName,
      city: city ?? this.city,
      street: street ?? this.street,
      district: district ?? this.district,
      postalCode: postalCode ?? this.postalCode,
      fullAddress: fullAddress ?? this.fullAddress,
      buildingNumber: buildingNumber ?? this.buildingNumber,
      floor: floor ?? this.floor,
      apartment: apartment ?? this.apartment,
      landmark: landmark ?? this.landmark,
      notes: notes ?? this.notes,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  @override
  List<Object?> get props => [
        id, title, recipientName, recipientPhone,
        countryId, countryName, city, street,
        district, postalCode, fullAddress,
        buildingNumber, floor, apartment,
        landmark, notes, latitude, longitude, isDefault,
      ];
}
