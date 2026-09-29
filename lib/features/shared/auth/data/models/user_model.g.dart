// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: (json['id'] as num?)?.toInt() ?? -1,
  name: json['name'] as String? ?? '',
  email: json['email'] as String? ?? '',
  phone: json['phone'] as String? ?? '',
  accessToken: json['access_token'] as String?,
  refreshToken: json['refresh_token'] as String?,
  userType:
      $enumDecodeNullable(_$UserTypeEnumMap, json['user_type']) ??
      UserType.unknown,
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'phone': instance.phone,
  'access_token': instance.accessToken,
  'refresh_token': instance.refreshToken,
  'user_type': instance.userType,
};

const _$UserTypeEnumMap = {
  UserType.individual: 'individual',
  UserType.business: 'business',
  UserType.admin: 'admin',
  UserType.customer: 'customer',
  UserType.unknown: 'unknown',
};
