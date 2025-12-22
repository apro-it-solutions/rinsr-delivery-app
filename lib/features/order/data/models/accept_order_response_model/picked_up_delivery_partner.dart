import 'package:json_annotation/json_annotation.dart';

part 'picked_up_delivery_partner.g.dart';

@JsonSerializable()
class PickedUpDeliveryPartner {
  @JsonKey(name: '_id')
  final String? id;
  @JsonKey(name: 'company_name')
  final String? companyName;
  final String? location;
  @JsonKey(name: 'phone_number')
  final String? phoneNumber;
  @JsonKey(name: 'device_token')
  final String? deviceToken;
  final List<String>? services;
  @JsonKey(name: 'is_active')
  final bool? isActive;
  @JsonKey(name: 'total_completed_orders')
  final int? totalCompletedOrders;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  @JsonKey(name: '__v')
  final int? v;

  const PickedUpDeliveryPartner({
    this.id,
    this.companyName,
    this.location,
    this.phoneNumber,
    this.deviceToken,
    this.services,
    this.isActive,
    this.totalCompletedOrders,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory PickedUpDeliveryPartner.fromJson(Map<String, dynamic> json) {
    return _$PickedUpDeliveryPartnerFromJson(json);
  }

  Map<String, dynamic> toJson() => _$PickedUpDeliveryPartnerToJson(this);

  PickedUpDeliveryPartner copyWith({
    String? id,
    String? companyName,
    String? location,
    String? phoneNumber,
    String? deviceToken,
    List<String>? services,
    bool? isActive,
    int? totalCompletedOrders,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? v,
  }) {
    return PickedUpDeliveryPartner(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      location: location ?? this.location,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      deviceToken: deviceToken ?? this.deviceToken,
      services: services ?? this.services,
      isActive: isActive ?? this.isActive,
      totalCompletedOrders: totalCompletedOrders ?? this.totalCompletedOrders,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      v: v ?? this.v,
    );
  }
}
