import 'package:equatable/equatable.dart';

class ProfileAddress extends Equatable {
  final int id;
  final String title;
  final String city;
  final String street;

  const ProfileAddress({
    required this.id,
    required this.title,
    required this.city,
    required this.street,
  });

  @override
  List<Object?> get props => [id, title, city, street];
}

class UserProfile extends Equatable {
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
  final ProfileAddress? defaultAddress;

  const UserProfile({
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

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        avatarUrl,
        userType,
        status,
        preferredLanguage,
        preferredTheme,
        pushNotificationsEnabled,
        loyaltyPoints,
        defaultAddress,
      ];
}
