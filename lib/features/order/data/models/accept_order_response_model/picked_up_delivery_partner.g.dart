// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'picked_up_delivery_partner.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PickedUpDeliveryPartner _$PickedUpDeliveryPartnerFromJson(
  Map<String, dynamic> json,
) => PickedUpDeliveryPartner(
  id: json['_id'] as String?,
  companyName: json['company_name'] as String?,
  location: json['location'] as String?,
  phoneNumber: json['phone_number'] as String?,
  deviceToken: json['device_token'] as String?,
  services: (json['services'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  isActive: json['is_active'] as bool?,
  totalCompletedOrders: (json['total_completed_orders'] as num?)?.toInt(),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  v: (json['__v'] as num?)?.toInt(),
);

Map<String, dynamic> _$PickedUpDeliveryPartnerToJson(
  PickedUpDeliveryPartner instance,
) => <String, dynamic>{
  '_id': instance.id,
  'company_name': instance.companyName,
  'location': instance.location,
  'phone_number': instance.phoneNumber,
  'device_token': instance.deviceToken,
  'services': instance.services,
  'is_active': instance.isActive,
  'total_completed_orders': instance.totalCompletedOrders,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  '__v': instance.v,
};
