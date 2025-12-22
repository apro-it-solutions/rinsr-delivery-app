// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_id.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserId _$UserIdFromJson(Map<String, dynamic> json) => UserId(
  id: json['_id'] as String?,
  name: json['name'] as String?,
  phone: json['phone'] as String?,
  email: json['email'] as String?,
  loginMethod: json['login_method'] as String?,
  isVerified: json['is_verified'] as bool?,
  phoneVerified: json['phone_verified'] as bool?,
  emailVerified: json['email_verified'] as bool?,
  tokenVersion: (json['token_version'] as num?)?.toInt(),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  v: (json['__v'] as num?)?.toInt(),
  profileImage: json['profileImage'],
  deviceTokens: (json['device_tokens'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$UserIdToJson(UserId instance) => <String, dynamic>{
  '_id': instance.id,
  'name': instance.name,
  'phone': instance.phone,
  'email': instance.email,
  'login_method': instance.loginMethod,
  'is_verified': instance.isVerified,
  'phone_verified': instance.phoneVerified,
  'email_verified': instance.emailVerified,
  'token_version': instance.tokenVersion,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  '__v': instance.v,
  'profileImage': instance.profileImage,
  'device_tokens': instance.deviceTokens,
};
