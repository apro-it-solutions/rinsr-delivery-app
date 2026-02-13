// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firebase_auth_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FirebaseAuthResponseModel _$FirebaseAuthResponseModelFromJson(
  Map<String, dynamic> json,
) => FirebaseAuthResponseModel(
  message: json['message'] as String,
  isNewUser: json['isNewUser'] as bool,
  token: json['token'] as String,
  user: DeliveryPartner.fromJson(json['user'] as Map<String, dynamic>),
);

Map<String, dynamic> _$FirebaseAuthResponseModelToJson(
  FirebaseAuthResponseModel instance,
) => <String, dynamic>{
  'message': instance.message,
  'isNewUser': instance.isNewUser,
  'token': instance.token,
  'user': instance.user,
};
