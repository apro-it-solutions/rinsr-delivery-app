// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_line.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServiceLine _$ServiceLineFromJson(Map<String, dynamic> json) => ServiceLine(
  serviceId: json['service_id'] as String?,
  serviceName: json['service_name'] as String?,
  items: (json['items'] as List<dynamic>?)
      ?.map((e) => ServiceItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  subtotal: json['subtotal'] as num?,
  id: json['_id'] as String?,
);

Map<String, dynamic> _$ServiceLineToJson(ServiceLine instance) =>
    <String, dynamic>{
      'service_id': instance.serviceId,
      'service_name': instance.serviceName,
      'items': instance.items,
      'subtotal': instance.subtotal,
      '_id': instance.id,
    };
