import 'package:equatable/equatable.dart';
import 'package:rinsr_delivery_partner/features/home/domain/entities/get_orders_entity.dart';

class UpdateOrderResponseEntity extends Equatable {
  final bool? success;
  final String? message;
  final UpdateOrderDetailsEntity? order;

  const UpdateOrderResponseEntity({this.success, this.message, this.order});

  @override
  List<Object?> get props => [success, message, order];
}

class UpdateOrderDetailsEntity extends Equatable {
  final PickupTimeSlotEntity? pickupTimeSlot;
  final PickupAddressEntity? pickupAddress;
  final String? id;
  final String? userId;
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
  final String? vendorStatus;
  final DateTime? pickupNotificationAt;
  final bool? pickupNotificationSent;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;
  final HubIdEntity? hubId;
  final List<String>? deliveryPartnerIds;

  const UpdateOrderDetailsEntity({
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
  });

  @override
  List<Object?> get props => [
    pickupTimeSlot,
    pickupAddress,
    id,
    userId,
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
    vendorStatus,
    pickupNotificationAt,
    pickupNotificationSent,
    createdAt,
    updatedAt,
    v,
    hubId,
    deliveryPartnerIds,
  ];
}
