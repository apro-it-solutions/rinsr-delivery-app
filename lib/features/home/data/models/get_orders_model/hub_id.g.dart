// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hub_id.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HubId _$HubIdFromJson(Map<String, dynamic> json) => HubId(
  id: json['_id'] as String?,
  name: json['name'] as String?,
  location: json['location'] as String?,
  locationCoordinates: json['location_coordinates'] as String?,
  primaryContact: json['primary_contact'] as String?,
  secondaryContact: json['secondary_contact'] as String?,
  vendorIds: (json['vendor_ids'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  v: (json['__v'] as num?)?.toInt(),
  deliveryPartnerIds: (json['delivery_partner_ids'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$HubIdToJson(HubId instance) => <String, dynamic>{
  '_id': instance.id,
  'name': instance.name,
  'location': instance.location,
  'location_coordinates': instance.locationCoordinates,
  'primary_contact': instance.primaryContact,
  'secondary_contact': instance.secondaryContact,
  'vendor_ids': instance.vendorIds,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  '__v': instance.v,
  'delivery_partner_ids': instance.deliveryPartnerIds,
};
