// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_id.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServiceId _$ServiceIdFromJson(Map<String, dynamic> json) => ServiceId(
  id: json['_id'] as String?,
  name: json['name'] as String?,
  price: (json['price'] as num?)?.toInt(),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  v: (json['__v'] as num?)?.toInt(),
);

Map<String, dynamic> _$ServiceIdToJson(ServiceId instance) => <String, dynamic>{
  '_id': instance.id,
  'name': instance.name,
  'price': instance.price,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  '__v': instance.v,
};
