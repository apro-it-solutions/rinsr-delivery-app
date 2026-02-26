import 'package:equatable/equatable.dart';

import '../../../home/domain/entities/get_orders_entity.dart';

class AcceptOrderResponseEntity extends Equatable {
  final bool? success;
  final String? message;
  final AcceptOrderDetailsEntity? order;
  const AcceptOrderResponseEntity({
    required this.success,
    required this.message,
    required this.order,
  });

  String? get orderId => order?.orderId;

  @override
  List<Object?> get props => [success, message, order];
}

class AcceptOrderDetailsEntity extends Equatable {
  final AcceptDeliveryUpdatesEntity? deliveryUpdates;
  final PickupTimeSlotEntity? pickupTimeSlot;
  final PickupAddressEntity? pickupAddress;
  final SubscriptionSnapshotEntity? subscriptionSnapshot;
  final String? orderId;
  final String? userId;
  final String? subscriptionId;
  final String? planId;
  final DateTime? pickupDate;
  final ServiceIdEntity? serviceId;
  final dynamic addons;
  final String? totalWeightKg;
  final String? totalNoOfClothes;
  final String? heavyItems;
  final String? deliveryDate;
  final int? estimateTotalPrice;
  final int? basePrice;
  final int? addonPrice;
  final int? totalPrice;
  final String? status;
  final String? orderType;
  final String? paymentStatus;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;
  final HubIdEntity? hubId;
  final String? vendorStatus;
  final VendorDetailsEntity? vendorId;
  final List<dynamic>? deliveryPartnerIds;
  final dynamic pickedUpDeliveryPartner;
  final bool? pickupNotificationSent;
  final List<dynamic>? vendorIds;

  const AcceptOrderDetailsEntity({
    this.deliveryUpdates,
    this.pickupTimeSlot,
    this.pickupAddress,
    this.subscriptionSnapshot,
    this.orderId,
    this.userId,
    this.subscriptionId,
    this.planId,
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
    this.createdAt,
    this.updatedAt,
    this.v,
    this.hubId,
    this.vendorStatus,
    this.vendorId,
    this.deliveryPartnerIds,
    this.pickedUpDeliveryPartner,
    this.pickupNotificationSent,
    this.vendorIds,
  });

  @override
  List<Object?> get props => [
    deliveryUpdates,
    pickupTimeSlot,
    pickupAddress,
    subscriptionSnapshot,
    orderId,
    userId,
    subscriptionId,
    planId,
    pickupDate,
    serviceId,
    addons,
    totalWeightKg,
    totalNoOfClothes,
    heavyItems,
    deliveryDate,
    estimateTotalPrice,
    basePrice,
    addonPrice,
    totalPrice,
    status,
    orderType,
    paymentStatus,
    createdAt,
    updatedAt,
    v,
    hubId,
    vendorStatus,
    vendorId,
    deliveryPartnerIds,
    pickedUpDeliveryPartner,
    pickupNotificationSent,
    vendorIds,
  ];
}

class AcceptDeliveryUpdatesEntity extends Equatable {
  final String? currentDeliveryPartnerId;
  final List<DeliveryUpdateItemEntity>? delivered;
  final List<DeliveryUpdateItemEntity>? pickedUp;

  const AcceptDeliveryUpdatesEntity({
    this.currentDeliveryPartnerId,
    this.delivered,
    this.pickedUp,
  });

  @override
  List<Object?> get props => [currentDeliveryPartnerId, delivered, pickedUp];
}
