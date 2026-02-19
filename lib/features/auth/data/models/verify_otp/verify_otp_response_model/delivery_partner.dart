import 'package:json_annotation/json_annotation.dart';

import '../../../../domain/entities/verify_user/verify_user_response_entity.dart';

part 'delivery_partner.g.dart';

@JsonSerializable()
class DeliveryPartner extends DeliveryPartnerEntity {
  @override
  @JsonKey(name: '_id')
  final String? id;
  @override
  @JsonKey(name: 'company_name')
  final String? companyName;
  @override
  final String? location;
  @override
  @JsonKey(name: 'phone_number')
  final String? phoneNumber;
  @JsonKey(name: 'device_tokens')
  final List<String>? deviceTokens;
  @override
  final List<String>? services;
  @override
  @JsonKey(name: 'is_active')
  final bool? isActive;
  @override
  @JsonKey(name: 'total_completed_orders')
  final int? totalCompletedOrders;
  @override
  @JsonKey(name: 'current_day_stats')
  final Map<String, dynamic>? currentDayStats;
  @override
  @JsonKey(name: 'price_per_kilometre')
  final num? pricePerKilometre; 
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
  @JsonKey(name: '__v')
  final int? v;

  const DeliveryPartner({
    this.id,
    this.companyName,
    this.location,
    this.phoneNumber,
    this.deviceTokens,
    this.services,
    this.isActive,
    this.totalCompletedOrders,
    this.currentDayStats,
    this.pricePerKilometre,
    this.createdAt,
    this.updatedAt,
    this.v,
  }) : super(
         id: id,
         companyName: companyName,
         location: location,
         phoneNumber: phoneNumber,
         services: services,
         isActive: isActive,
         totalCompletedOrders: totalCompletedOrders,
         currentDayStats: currentDayStats,
         pricePerKilometre: pricePerKilometre,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  factory DeliveryPartner.fromJson(Map<String, dynamic> json) {
    return _$DeliveryPartnerFromJson(json);
  }

  Map<String, dynamic> toJson() => _$DeliveryPartnerToJson(this);

  DeliveryPartner copyWith({
    String? id,
    String? companyName,
    String? location,
    String? phoneNumber,
    List<String>? deviceTokens,
    List<String>? services,
    bool? isActive,
    int? totalCompletedOrders,
    Map<String, dynamic>? currentDayStats,
    num? pricePerKilometre,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? v,
  }) {
    return DeliveryPartner(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      location: location ?? this.location,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      deviceTokens: deviceTokens ?? this.deviceTokens,
      services: services ?? this.services,
      isActive: isActive ?? this.isActive,
      totalCompletedOrders: totalCompletedOrders ?? this.totalCompletedOrders,
      currentDayStats: currentDayStats ?? this.currentDayStats,
      pricePerKilometre: pricePerKilometre ?? this.pricePerKilometre,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      v: v ?? this.v,
    );
  }
}
