// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firebase_auth_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FirebaseAuthRequestModel _$FirebaseAuthRequestModelFromJson(
  Map<String, dynamic> json,
) => FirebaseAuthRequestModel(
  idToken: json['idToken'] as String,
  fcmToken: json['fcm_token'] as String?,
);

Map<String, dynamic> _$FirebaseAuthRequestModelToJson(
  FirebaseAuthRequestModel instance,
) => <String, dynamic>{
  'idToken': instance.idToken,
  'fcm_token': instance.fcmToken,
};
