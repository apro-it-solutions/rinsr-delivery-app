// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Order _$OrderFromJson(Map<String, dynamic> json) => Order(
  displayOrderID: (json['order_id'] as num?)?.toInt(),
  pickupTimeSlot: json['pickup_time_slot'] == null
      ? null
      : PickupTimeSlot.fromJson(
          json['pickup_time_slot'] as Map<String, dynamic>,
        ),
  pickupAddress: json['pickup_address'] == null
      ? null
      : PickupAddress.fromJson(json['pickup_address'] as Map<String, dynamic>),
  id: json['_id'] as String?,
  userId: json['user_id'] == null
      ? null
      : UserId.fromJson(json['user_id'] as Map<String, dynamic>),
  pickupDate: json['pickup_date'] == null
      ? null
      : DateTime.parse(json['pickup_date'] as String),
  serviceId: json['service_id'] == null
      ? null
      : ServiceId.fromJson(json['service_id'] as Map<String, dynamic>),
  addons: json['addons'],
  totalWeightKg: json['total_weight_kg'] as String?,
  totalNoOfClothes: json['total_no_of_clothes'] as String?,
  heavyItems: json['heavy_items'] as String?,
  deliveryDate: json['delivery_date'] as String?,
  estimateTotalPrice: (json['estimate_total_price'] as num?)?.toInt(),
  basePrice: (json['base_price'] as num?)?.toInt(),
  addonPrice: (json['addon_price'] as num?)?.toInt(),
  totalPrice: (json['total_price'] as num?)?.toInt(),
  status: json['status'] as String?,
  orderType: json['order_type'] as String?,
  paymentStatus: json['payment_status'] as String?,
  vendorStatus: json['vendor_status'] as String?,
  pickupNotificationAt: json['pickup_notification_at'] == null
      ? null
      : DateTime.parse(json['pickup_notification_at'] as String),
  pickupNotificationSent: json['pickup_notification_sent'] as bool?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  v: (json['__v'] as num?)?.toInt(),
  hubId: json['hub_id'] == null
      ? null
      : HubId.fromJson(json['hub_id'] as Map<String, dynamic>),
  vendorId: json['vendor_id'] == null
      ? null
      : VendorId.fromJson(json['vendor_id'] as Map<String, dynamic>),
  subscriptionSnapshot: json['subscription_snapshot'] == null
      ? null
      : SubscriptionSnapshot.fromJson(
          json['subscription_snapshot'] as Map<String, dynamic>,
        ),
  subscriptionId: json['subscription_id'] == null
      ? null
      : SubscriptionId.fromJson(
          json['subscription_id'] as Map<String, dynamic>,
        ),
  planId: json['plan_id'] == null
      ? null
      : PlanId.fromJson(json['plan_id'] as Map<String, dynamic>),
  photoPath: json['photoPath'] as String?,
  cancelReason: json['cancel_reason'] as String?,
  deliveryUpdates: json['delivery_updates'] == null
      ? null
      : DeliveryUpdates.fromJson(
          json['delivery_updates'] as Map<String, dynamic>,
        ),
  pickedUpDeliveryPartnerId: json['picked_up_delivery_partner'] as String?,
  orderReturnedDeliveryPartner:
      json['order_returned_delivery_partner'] as String?,
  barcode: json['barcode_id'] as String?,
);

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
  'pickup_time_slot': instance.pickupTimeSlot,
  'pickup_address': instance.pickupAddress,
  'order_id': instance.displayOrderID,
  '_id': instance.id,
  'user_id': instance.userId,
  'pickup_date': instance.pickupDate?.toIso8601String(),
  'service_id': instance.serviceId,
  'addons': instance.addons,
  'total_weight_kg': instance.totalWeightKg,
  'total_no_of_clothes': instance.totalNoOfClothes,
  'heavy_items': instance.heavyItems,
  'delivery_date': instance.deliveryDate,
  'estimate_total_price': instance.estimateTotalPrice,
  'base_price': instance.basePrice,
  'addon_price': instance.addonPrice,
  'total_price': instance.totalPrice,
  'status': instance.status,
  'order_type': instance.orderType,
  'payment_status': instance.paymentStatus,
  'vendor_status': instance.vendorStatus,
  'pickup_notification_at': instance.pickupNotificationAt?.toIso8601String(),
  'pickup_notification_sent': instance.pickupNotificationSent,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  '__v': instance.v,
  'hub_id': instance.hubId,
  'vendor_id': instance.vendorId,
  'subscription_snapshot': instance.subscriptionSnapshot,
  'subscription_id': instance.subscriptionId,
  'plan_id': instance.planId,
  'photoPath': instance.photoPath,
  'cancel_reason': instance.cancelReason,
  'delivery_updates': instance.deliveryUpdates,
  'picked_up_delivery_partner': instance.pickedUpDeliveryPartnerId,
  'order_returned_delivery_partner': instance.orderReturnedDeliveryPartner,
  'barcode_id': instance.barcode,
};
