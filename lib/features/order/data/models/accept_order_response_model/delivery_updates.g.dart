// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery_updates.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeliveryUpdates _$DeliveryUpdatesFromJson(Map<String, dynamic> json) =>
    DeliveryUpdates(
      pickedUp: (json['picked_up'] as List<dynamic>?)
          ?.map((e) => PickedUp.fromJson(e as Map<String, dynamic>))
          .toList(),
      delivered: json['delivered'] as List<dynamic>?,
      currentDeliveryPartnerId: json['current_delivery_partner_id'] as String?,
    );

Map<String, dynamic> _$DeliveryUpdatesToJson(DeliveryUpdates instance) =>
    <String, dynamic>{
      'picked_up': instance.pickedUp,
      'delivered': instance.delivered,
      'current_delivery_partner_id': instance.currentDeliveryPartnerId,
    };
