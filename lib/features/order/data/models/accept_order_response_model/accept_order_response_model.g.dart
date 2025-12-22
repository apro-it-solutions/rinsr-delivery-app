// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accept_order_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AcceptOrderResponseModel _$AcceptOrderResponseModelFromJson(
  Map<String, dynamic> json,
) => AcceptOrderResponseModel(
  success: json['success'] as bool?,
  message: json['message'] as String?,
  order: json['order'] == null
      ? null
      : Order.fromJson(json['order'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AcceptOrderResponseModelToJson(
  AcceptOrderResponseModel instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'order': instance.order,
};
