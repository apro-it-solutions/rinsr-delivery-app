import 'package:json_annotation/json_annotation.dart';

import '../../../domain/entities/update_order_response_entity.dart';
import 'hub_id.dart';
import 'pickup_address.dart';
import 'pickup_time_slot.dart';
import 'service_id.dart';

part 'order.g.dart';

@JsonSerializable()
class Order extends UpdateOrderDetailsEntity {
  @override
  @JsonKey(name: 'pickup_time_slot')
  final PickupTimeSlot? pickupTimeSlot;
  @override
  @JsonKey(name: 'pickup_address')
  final PickupAddress? pickupAddress;
  @override
  @JsonKey(name: '_id')
  final String? id;
  @override
  @JsonKey(name: 'user_id')
  final String? userId;
  @override
  @JsonKey(name: 'pickup_date')
  final DateTime? pickupDate;
  @override
  @JsonKey(name: 'service_id')
  final ServiceId? serviceId;
  @override
  final dynamic addons;
  @override
  @JsonKey(name: 'total_weight_kg')
  final String? totalWeightKg;
  @override
  @JsonKey(name: 'total_no_of_clothes')
  final String? totalNoOfClothes;
  @override
  @JsonKey(name: 'heavy_items')
  final String? heavyItems;
  @override
  @JsonKey(name: 'delivery_date')
  final String? deliveryDate;
  @override
  @JsonKey(name: 'estimate_total_price')
  final int? estimateTotalPrice;
  @override
  @JsonKey(name: 'base_price')
  final int? basePrice;
  @override
  @JsonKey(name: 'addon_price')
  final int? addonPrice;
  @override
  @JsonKey(name: 'total_price')
  final int? totalPrice;
  @override
  final String? status;
  @override
  @JsonKey(name: 'order_type')
  final String? orderType;
  @override
  @JsonKey(name: 'payment_status')
  final String? paymentStatus;
  @override
  @JsonKey(name: 'vendor_status')
  final String? vendorStatus;
  @override
  @JsonKey(name: 'pickup_notification_at')
  final DateTime? pickupNotificationAt;
  @override
  @JsonKey(name: 'pickup_notification_sent')
  final bool? pickupNotificationSent;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
  @override
  @JsonKey(name: '__v')
  final int? v;
  @override
  @JsonKey(name: 'hub_id')
  final HubId? hubId;
  @override
  @JsonKey(name: 'delivery_partner_ids')
  final List<String>? deliveryPartnerIds;

  const Order({
    this.pickupTimeSlot,
    this.pickupAddress,
    this.id,
    this.userId,
    this.pickupDate,
    this.serviceId,
    this.addons,
    this.totalWeightKg,
    this.totalNoOfClothes,
    this.heavyItems,
    this.deliveryDate,
    this.estimateTotalPrice,
    this.basePrice,
    this.addonPrice,
    this.totalPrice,
    this.status,
    this.orderType,
    this.paymentStatus,
    this.vendorStatus,
    this.pickupNotificationAt,
    this.pickupNotificationSent,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.hubId,
    this.deliveryPartnerIds,
  }) : super(
         pickupTimeSlot: pickupTimeSlot,
         pickupAddress: pickupAddress,
         id: id,
         userId: userId,
         pickupDate: pickupDate,
         serviceId: serviceId,
         addons: addons,
         totalWeightKg: totalWeightKg,
         totalNoOfClothes: totalNoOfClothes,
         heavyItems: heavyItems,
         deliveryDate: deliveryDate,
         estimateTotalPrice: estimateTotalPrice,
         basePrice: basePrice,
         addonPrice: addonPrice,
         totalPrice: totalPrice,
         status: status,
         orderType: orderType,
         paymentStatus: paymentStatus,
         vendorStatus: vendorStatus,
         pickupNotificationAt: pickupNotificationAt,
         pickupNotificationSent: pickupNotificationSent,
         createdAt: createdAt,
         updatedAt: updatedAt,
         v: v,
         hubId: hubId,
         deliveryPartnerIds: deliveryPartnerIds,
       );

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);

  Map<String, dynamic> toJson() => _$OrderToJson(this);

  Order copyWith({
    PickupTimeSlot? pickupTimeSlot,
    PickupAddress? pickupAddress,
    String? id,
    String? userId,
    DateTime? pickupDate,
    ServiceId? serviceId,
    dynamic addons,
    String? totalWeightKg,
    String? totalNoOfClothes,
    String? heavyItems,
    String? deliveryDate,
    int? estimateTotalPrice,
    int? basePrice,
    int? addonPrice,
    int? totalPrice,
    String? status,
    String? orderType,
    String? paymentStatus,
    String? vendorStatus,
    DateTime? pickupNotificationAt,
    bool? pickupNotificationSent,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? v,
    HubId? hubId,
    List<String>? deliveryPartnerIds,
  }) {
    return Order(
      pickupTimeSlot: pickupTimeSlot ?? this.pickupTimeSlot,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      id: id ?? this.id,
      userId: userId ?? this.userId,
      pickupDate: pickupDate ?? this.pickupDate,
      serviceId: serviceId ?? this.serviceId,
      addons: addons ?? this.addons,
      totalWeightKg: totalWeightKg ?? this.totalWeightKg,
      totalNoOfClothes: totalNoOfClothes ?? this.totalNoOfClothes,
      heavyItems: heavyItems ?? this.heavyItems,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      estimateTotalPrice: estimateTotalPrice ?? this.estimateTotalPrice,
      basePrice: basePrice ?? this.basePrice,
      addonPrice: addonPrice ?? this.addonPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      orderType: orderType ?? this.orderType,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      vendorStatus: vendorStatus ?? this.vendorStatus,
      pickupNotificationAt: pickupNotificationAt ?? this.pickupNotificationAt,
      pickupNotificationSent:
          pickupNotificationSent ?? this.pickupNotificationSent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      v: v ?? this.v,
      hubId: hubId ?? this.hubId,
      deliveryPartnerIds: deliveryPartnerIds ?? this.deliveryPartnerIds,
    );
  }
}
