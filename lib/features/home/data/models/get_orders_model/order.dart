import 'package:json_annotation/json_annotation.dart';

import '../../../domain/entities/get_orders_entity.dart';
import 'delivery_updates.dart';
import 'hub_id.dart';
import 'pickup_address.dart';
import 'pickup_time_slot.dart';
import 'plan_id.dart';
import 'service_id.dart';
import 'subscription_id.dart';
import 'subscription_snapshot.dart';
import 'user_id.dart';
import 'vendor_id.dart';

part 'order.g.dart';

@JsonSerializable()
class Order extends OrderDetailsEntity {
  @override
  @JsonKey(name: 'pickup_time_slot')
  final PickupTimeSlot? pickupTimeSlot;
  @override
  @JsonKey(name: 'pickup_address')
  final PickupAddress? pickupAddress;
  @override
  @JsonKey(name: 'order_id')
  final int? displayOrderID;
  @JsonKey(name: '_id')
  final String? id;
  @override
  @JsonKey(name: 'user_id')
  final UserId? userId;
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
  @JsonKey(name: 'vendor_id')
  final VendorId? vendorId;
  @override
  @JsonKey(name: 'subscription_snapshot')
  final SubscriptionSnapshot? subscriptionSnapshot;
  @override
  @JsonKey(name: 'subscription_id')
  final SubscriptionId? subscriptionId;
  @override
  @JsonKey(name: 'plan_id')
  final PlanId? planId;

  @override
  final String? photoPath;

  @override
  @JsonKey(name: 'cancel_reason')
  final String? cancelReason;

  @override
  @JsonKey(name: 'delivery_updates')
  final DeliveryUpdates? deliveryUpdates;

  @override
  @JsonKey(name: 'picked_up_delivery_partner')
  final String? pickedUpDeliveryPartnerId;

  @override
  @JsonKey(name: 'order_returned_delivery_partner')
  final String? orderReturnedDeliveryPartner;

  @override
  @JsonKey(name: 'barcode_id')
  final String? barcode;

  const Order({
    this.displayOrderID,
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
    this.vendorId,
    this.subscriptionSnapshot,
    this.subscriptionId,
    this.planId,
    this.photoPath,
    this.cancelReason,
    this.deliveryUpdates,
    this.pickedUpDeliveryPartnerId,
    this.orderReturnedDeliveryPartner,
    this.barcode,
  }) : super(
         orderReturnedDeliveryPartner: orderReturnedDeliveryPartner,
         pickedUpDeliveryPartnerId: pickedUpDeliveryPartnerId,
         deliveryUpdates: deliveryUpdates,
         orderId: id,
         vendorStatus: vendorStatus,
         status: status,
         vendorId: vendorId,
         totalWeightKg: totalWeightKg,
         hubId: hubId,
         deliveryDate: deliveryDate,
         pickupAddress: pickupAddress,
         serviceId: serviceId,
         addonPrice: addonPrice,
         totalPrice: totalPrice,
         basePrice: basePrice,
         estimateTotalPrice: estimateTotalPrice,
         totalNoOfClothes: totalNoOfClothes,
         heavyItems: heavyItems,
         orderType: orderType,
         paymentStatus: paymentStatus,
         pickupNotificationAt: pickupNotificationAt,
         pickupNotificationSent: pickupNotificationSent,
         createdAt: createdAt,
         updatedAt: updatedAt,
         v: v,
         subscriptionSnapshot: subscriptionSnapshot,
         subscriptionId: subscriptionId,
         planId: planId,
         addons: addons,
         userId: userId,
         pickupDate: pickupDate,
         pickupTimeSlot: pickupTimeSlot,
         photoPath: photoPath,
         cancelReason: cancelReason,
         displayOrderID: displayOrderID,
         barcode: barcode,
       );

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);

  Map<String, dynamic> toJson() => _$OrderToJson(this);

  @override
  Order copyWith({
    PickupTimeSlotEntity? pickupTimeSlot,
    PickupAddressEntity? pickupAddress,
    List<String>? deliveryPartnerIds,
    String? id,
    UserIdEntity? userId,
    DateTime? pickupDate,
    ServiceIdEntity? serviceId,
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
    HubIdEntity? hubId,
    VendorDetailsEntity? vendorId,
    SubscriptionSnapshotEntity? subscriptionSnapshot,
    SubscriptionIdEntity? subscriptionId,
    PlanIdEntity? planId,
    String? photoPath,
    String? cancelReason,
    String? orderId,
    int? displayOrderID,
  }) {
    return Order(
      pickupTimeSlot: pickupTimeSlot as PickupTimeSlot? ?? this.pickupTimeSlot,
      pickupAddress: pickupAddress as PickupAddress? ?? this.pickupAddress,
      id: id ?? orderId ?? this.id,
      userId: userId as UserId? ?? this.userId,
      pickupDate: pickupDate ?? this.pickupDate,
      serviceId: serviceId as ServiceId? ?? this.serviceId,
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
      hubId: hubId as HubId? ?? this.hubId,
      vendorId: vendorId as VendorId? ?? this.vendorId,
      subscriptionSnapshot:
          subscriptionSnapshot as SubscriptionSnapshot? ??
          this.subscriptionSnapshot,
      subscriptionId: subscriptionId as SubscriptionId? ?? this.subscriptionId,
      planId: planId as PlanId? ?? this.planId,
      photoPath: photoPath ?? this.photoPath,
      cancelReason: cancelReason ?? this.cancelReason,
      displayOrderID: displayOrderID ?? this.displayOrderID,
    );
  }
}
