import 'package:equatable/equatable.dart';

class BranchEntity extends Equatable {
  final int id;
  final String name;
  final String? code;
  final String address;
  final String city;
  final String? phone;
  final String? openingHours;
  final double? latitude;
  final double? longitude;

  final bool isActive;

  const BranchEntity({
    required this.id,
    required this.name,
    this.code,
    required this.address,
    required this.city,
    this.phone,
    this.openingHours,
    this.latitude,
    this.longitude,
    this.isActive = true,
  });

  factory BranchEntity.fromJson(Map<String, dynamic> json) {
    return BranchEntity(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      code: json['code'] as String?,
      address: json['address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      phone: json['phone'] as String?,
      openingHours: json['opening_hours'] as String? ?? json['openingHours'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      isActive: json['active'] == true || json['is_active'] == true || (json['active'] == null && json['is_active'] == null),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    if (code != null) 'code': code,
    'address': address,
    'city': city,
    if (phone != null) 'phone': phone,
    if (openingHours != null) 'opening_hours': openingHours,
    if (latitude != null) 'latitude': latitude,
    if (longitude != null) 'longitude': longitude,
    'active': isActive,
  };

  BranchEntity copyWith({
    int? id,
    String? name,
    String? code,
    String? address,
    String? city,
    String? phone,
    String? openingHours,
    double? latitude,
    double? longitude,
    bool? isActive,
  }) {
    return BranchEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      address: address ?? this.address,
      city: city ?? this.city,
      phone: phone ?? this.phone,
      openingHours: openingHours ?? this.openingHours,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [id, name, code, address, city, phone, openingHours, latitude, longitude, isActive];
}
