import 'package:equatable/equatable.dart';
import 'user_type.dart';

class User extends Equatable {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String? accessToken;
  final String? refreshToken;
  final UserType userType;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.accessToken,
    this.refreshToken,
    this.userType = UserType.unknown,
  });

  @override
  List<Object?> get props => [id, name, email, phone, accessToken, refreshToken, userType];
}
