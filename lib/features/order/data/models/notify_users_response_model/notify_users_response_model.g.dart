// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notify_users_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotifyUsersResponseModel _$NotifyUsersResponseModelFromJson(
  Map<String, dynamic> json,
) => NotifyUsersResponseModel(
  success: json['success'] as bool?,
  message: json['message'] as String?,
);

Map<String, dynamic> _$NotifyUsersResponseModelToJson(
  NotifyUsersResponseModel instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
};
