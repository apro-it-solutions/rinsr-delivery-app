// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery_updates.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeliveryUpdates _$DeliveryUpdatesFromJson(Map<String, dynamic> json) =>
    DeliveryUpdates(
      currentDeliveryPartnerId: json['current_delivery_partner_id'] as String?,
      delivered: (json['delivered'] as List<dynamic>?)
          ?.map((e) => DeliveryUpdateItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      pickedUp: (json['picked_up'] as List<dynamic>?)
          ?.map((e) => DeliveryUpdateItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DeliveryUpdatesToJson(DeliveryUpdates instance) =>
    <String, dynamic>{
      'current_delivery_partner_id': instance.currentDeliveryPartnerId,
      'delivered': instance.delivered,
      'picked_up': instance.pickedUp,
    };

DeliveryUpdateItem _$DeliveryUpdateItemFromJson(Map<String, dynamic> json) =>
    DeliveryUpdateItem(
      status: json['status'] as String?,
      deliveryId: json['delivery_id'] as String?,
      timestamp: json['timestamp'] == null
          ? null
          : DateTime.parse(json['timestamp'] as String),
      id: json['_id'] as String?,
    );

Map<String, dynamic> _$DeliveryUpdateItemToJson(DeliveryUpdateItem instance) =>
    <String, dynamic>{
      'status': instance.status,
      'delivery_id': instance.deliveryId,
      'timestamp': instance.timestamp?.toIso8601String(),
      '_id': instance.id,
    };
