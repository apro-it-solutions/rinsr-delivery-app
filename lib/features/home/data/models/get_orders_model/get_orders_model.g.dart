// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_orders_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetOrdersModel _$GetOrdersModelFromJson(Map<String, dynamic> json) =>
    GetOrdersModel(
      success: json['success'] as bool?,
      count: (json['count'] as num?)?.toInt(),
      orders: (json['orders'] as List<dynamic>?)
          ?.map((e) => Order.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GetOrdersModelToJson(GetOrdersModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'count': instance.count,
      'orders': instance.orders,
    };
