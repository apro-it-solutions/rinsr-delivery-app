import 'package:json_annotation/json_annotation.dart';

import '../../../domain/entities/accept_order_response_entity.dart';
import 'delivery_updates.dart';
import 'picked_up_delivery_partner.dart';
import 'pickup_address.dart';
import 'pickup_time_slot.dart';
import 'service_id.dart';

part 'order.g.dart';

@JsonSerializable()
class Order extends AcceptOrderDetailsEntity {
  @override
  @JsonKey(name: 'delivery_updates')
  final DeliveryUpdates? deliveryUpdates;
  @override
  @JsonKey(name: 'pickup_time_slot')
  final PickupTimeSlot? pickupTimeSlot;
  @override
  @JsonKey(name: 'pickup_address')
  final PickupAddress? pickupAddress;
  @JsonKey(name: '_id')
  final String? id;

  @override
  String? get orderId => id;

  @override
  @JsonKey(name: 'user_id')
  final String? userId;
  @override
  @JsonKey(name: 'vendor_ids')
  final List<dynamic>? vendorIds;
  @override
  @JsonKey(name: 'delivery_partner_ids')
  final List<dynamic>? deliveryPartnerIds;
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
  @JsonKey(name: 'picked_up_delivery_partner')
  final PickedUpDeliveryPartner? pickedUpDeliveryPartner;

  const Order({
    this.deliveryUpdates,
    this.pickupTimeSlot,
    this.pickupAddress,
    this.id,
    this.userId,
    this.vendorIds,
    this.deliveryPartnerIds,
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
    this.pickedUpDeliveryPartner,
  });

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);

  Map<String, dynamic> toJson() => _$OrderToJson(this);

  Order copyWith({
    DeliveryUpdates? deliveryUpdates,
    PickupTimeSlot? pickupTimeSlot,
    PickupAddress? pickupAddress,
    String? id,
    String? userId,
    List<dynamic>? vendorIds,
    List<dynamic>? deliveryPartnerIds,
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
    PickedUpDeliveryPartner? pickedUpDeliveryPartner,
  }) {
    return Order(
      deliveryUpdates: deliveryUpdates ?? this.deliveryUpdates,
      pickupTimeSlot: pickupTimeSlot ?? this.pickupTimeSlot,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      id: id ?? this.id,
      userId: userId ?? this.userId,
      vendorIds: vendorIds ?? this.vendorIds,
      deliveryPartnerIds: deliveryPartnerIds ?? this.deliveryPartnerIds,
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
      pickedUpDeliveryPartner:
          pickedUpDeliveryPartner ?? this.pickedUpDeliveryPartner,
    );
  }
}
