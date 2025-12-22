// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pickup_address.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PickupAddress _$PickupAddressFromJson(Map<String, dynamic> json) =>
    PickupAddress(
      label: json['label'] as String?,
      addressLine: json['address_line'] as String?,
    );

Map<String, dynamic> _$PickupAddressToJson(PickupAddress instance) =>
    <String, dynamic>{
      'label': instance.label,
      'address_line': instance.addressLine,
    };
