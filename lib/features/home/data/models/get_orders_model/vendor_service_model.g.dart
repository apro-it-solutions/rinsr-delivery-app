// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vendor_service_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VendorServiceModel _$VendorServiceModelFromJson(Map<String, dynamic> json) {
  return VendorServiceModel(
    name: json['name'] as String?,
    price: json['price'] as num? ?? 0,
  );
}

Map<String, dynamic> _$VendorServiceModelToJson(VendorServiceModel instance) =>
    <String, dynamic>{'name': instance.name, 'price': instance.price};
