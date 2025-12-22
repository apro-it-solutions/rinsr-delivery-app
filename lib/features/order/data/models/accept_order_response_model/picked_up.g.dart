// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'picked_up.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PickedUp _$PickedUpFromJson(Map<String, dynamic> json) => PickedUp(
  status: json['status'] as String?,
  deliveryId: json['delivery_id'] as String?,
  timestamp: json['timestamp'] == null
      ? null
      : DateTime.parse(json['timestamp'] as String),
  id: json['_id'] as String?,
);

Map<String, dynamic> _$PickedUpToJson(PickedUp instance) => <String, dynamic>{
  'status': instance.status,
  'delivery_id': instance.deliveryId,
  'timestamp': instance.timestamp?.toIso8601String(),
  '_id': instance.id,
};
