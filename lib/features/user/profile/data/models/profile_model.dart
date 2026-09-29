import '../../domain/entities/profile.dart';

class ProfileAddressModel {
  final int id;
  final String title;
  final String city;
  final String street;

  const ProfileAddressModel({
    required this.id,
    this.title = '',
    this.city = '',
    this.street = '',
  });

  factory ProfileAddressModel.fromJson(Map<String, dynamic> json) {
    return ProfileAddressModel(
      id: json['id'] as int? ?? -1,
      title: json['title'] as String? ?? '',
      city: json['city'] as String? ?? '',
      street: json['street'] as String? ?? '',
    );
  }

  ProfileAddress toDomain() {
    return ProfileAddress(
      id: id,
      title: title,
      city: city,
      street: street,
    );
  }
}

class UserProfileModel {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String avatarUrl;
  final String userType;
  final String status;
  final String preferredLanguage;
  final String preferredTheme;
  final bool pushNotificationsEnabled;
  final int loyaltyPoints;
  final ProfileAddressModel? defaultAddress;

  const UserProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.avatarUrl,
    required this.userType,
    required this.status,
    required this.preferredLanguage,
    required this.preferredTheme,
    required this.pushNotificationsEnabled,
    required this.loyaltyPoints,
    this.defaultAddress,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    String parseString(dynamic val) {
      if (val == null || val == false) return '';
      return val.toString();
    }

    return UserProfileModel(
      id: json['id'] as int? ?? -1,
      name: parseString(json['name']),
      email: parseString(json['email']),
      phone: parseString(json['phone']),
      avatarUrl: parseString(json['avatar_url'] ?? json['avatar']),
      userType: json['user_type'] is String ? json['user_type'] as String : 'customer',
      status: json['status'] is String ? json['status'] as String : 'active',
      preferredLanguage: parseString(json['preferred_language']).isEmpty ? 'ar' : parseString(json['preferred_language']),
      preferredTheme: parseString(json['preferred_theme']).isEmpty ? 'light' : parseString(json['preferred_theme']),
      pushNotificationsEnabled: json['push_notifications_enabled'] as bool? ?? true,
      loyaltyPoints: (json['loyalty_points'] as num?)?.toInt() ?? 0,
      defaultAddress: json['default_address'] != null
          ? ProfileAddressModel.fromJson(json['default_address'] as Map<String, dynamic>)
          : null,
    );
  }

  UserProfile toDomain() {
    return UserProfile(
      id: id,
      name: name,
      email: email,
      phone: phone,
      avatarUrl: avatarUrl,
      userType: userType,
      status: status,
      preferredLanguage: preferredLanguage,
      preferredTheme: preferredTheme,
      pushNotificationsEnabled: pushNotificationsEnabled,
      loyaltyPoints: loyaltyPoints,
      defaultAddress: defaultAddress?.toDomain(),
    );
  }
}
