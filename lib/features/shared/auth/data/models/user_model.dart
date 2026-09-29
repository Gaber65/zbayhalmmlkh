import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/user_type.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends User {
  const UserModel({
    super.id = -1,
    super.name = '',
    super.email = '',
    super.phone = '',
    @JsonKey(name: 'access_token') super.accessToken,
    @JsonKey(name: 'refresh_token') super.refreshToken,
    @JsonKey(name: 'user_type') super.userType = UserType.unknown,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  User toDomain() {
    return User(
      id: id,
      name: name,
      email: email,
      phone: phone,
      accessToken: accessToken,
      refreshToken: refreshToken,
      userType: userType,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    phone,
    accessToken,
    refreshToken,
    userType,
  ];
}
