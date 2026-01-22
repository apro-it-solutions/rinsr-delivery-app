import 'package:json_annotation/json_annotation.dart';

import '../../../domain/entities/get_orders_entity.dart';
import 'vendor_service_model.dart';

part 'vendor_id.g.dart';

@JsonSerializable()
class VendorId extends VendorDetailsEntity {
  @override
  @JsonKey(name: '_id')
  final String? id;
  @override
  @JsonKey(name: 'company_name')
  final String? companyName;
  @override
  final String? location;
  @override
  @JsonKey(name: 'location_coordinates')
  final String? locationCoordinates;
  @override
  @JsonKey(name: 'phone_number')
  final String? phoneNumber;
  @override
  @JsonKey(name: 'device_tokens')
  final List<String>? deviceTokens;
  @override
  final List<VendorServiceModel>? services;
  @override
  @JsonKey(name: 'is_active')
  final bool? isActive;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
  @override
  @JsonKey(name: '__v')
  final int? v;

  const VendorId({
    this.id,
    this.companyName,
    this.location,
    this.locationCoordinates,
    this.phoneNumber,
    this.deviceTokens,
    this.services,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.v,
  }) : super(
         id: id,
         companyName: companyName,
         location: location,
         locationCoordinates: locationCoordinates,
         phoneNumber: phoneNumber,
         deviceTokens: deviceTokens,
         services: services,
         isActive: isActive,
         createdAt: createdAt,
         updatedAt: updatedAt,
         v: v,
       );

  factory VendorId.fromJson(Map<String, dynamic> json) {
    return _$VendorIdFromJson(json);
  }

  Map<String, dynamic> toJson() => _$VendorIdToJson(this);

  VendorId copyWith({
    String? id,
    String? companyName,
    String? location,
    String? locationCoordinates,
    String? phoneNumber,
    List<String>? deviceTokens,
    List<VendorServiceModel>? services,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? v,
  }) {
    return VendorId(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      location: location ?? this.location,
      locationCoordinates: locationCoordinates ?? this.locationCoordinates,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      deviceTokens: deviceTokens ?? this.deviceTokens,
      services: services ?? this.services,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      v: v ?? this.v,
    );
  }
}

