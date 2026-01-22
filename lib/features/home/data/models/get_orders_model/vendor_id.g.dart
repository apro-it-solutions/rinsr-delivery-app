// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vendor_id.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VendorId _$VendorIdFromJson(Map<String, dynamic> json) => VendorId(
  id: json['_id'] as String?,
  companyName: json['company_name'] as String?,
  location: json['location'] as String?,
  locationCoordinates: json['location_coordinates'] as String?,
  phoneNumber: json['phone_number'] as String?,
  deviceTokens: (json['device_tokens'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  services: (json['services'] as List<dynamic>?)
      ?.map((e) => VendorServiceModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  isActive: json['is_active'] as bool?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  v: (json['__v'] as num?)?.toInt(),
);

Map<String, dynamic> _$VendorIdToJson(VendorId instance) => <String, dynamic>{
  '_id': instance.id,
  'company_name': instance.companyName,
  'location': instance.location,
  'location_coordinates': instance.locationCoordinates,
  'phone_number': instance.phoneNumber,
  'device_tokens': instance.deviceTokens,
  'services': instance.services,
  'is_active': instance.isActive,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  '__v': instance.v,
};
