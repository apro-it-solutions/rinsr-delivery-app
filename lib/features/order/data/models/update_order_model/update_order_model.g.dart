// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateOrderModel _$UpdateOrderModelFromJson(Map<String, dynamic> json) =>
    UpdateOrderModel(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      order: json['order'] == null
          ? null
          : Order.fromJson(json['order'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UpdateOrderModelToJson(UpdateOrderModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'order': instance.order,
    };
