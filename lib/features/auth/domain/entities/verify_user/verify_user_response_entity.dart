import 'package:equatable/equatable.dart';

class VerifyUserResponseEntity extends Equatable {
  final bool? success;
  final String? message;
  final String? token;
  final DeliveryPartnerEntity? deliveryPartner;

  const VerifyUserResponseEntity({
    this.success,
    this.message,
    this.token,
    this.deliveryPartner,
  });

  @override
  List<Object?> get props => [success, message, token, deliveryPartner];

  @override
  bool get stringify => true;
}

class DeliveryPartnerEntity extends Equatable {
  final String? id;
  final String? companyName;
  final String? location;
  final String? phoneNumber;
  final List<String>? services;
  final bool? isActive;
  final int? totalCompletedOrders;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const DeliveryPartnerEntity({
    this.id,
    this.companyName,
    this.location,
    this.phoneNumber,
    this.services,
    this.isActive,
    this.totalCompletedOrders,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    companyName,
    location,
    phoneNumber,
    services,
    isActive,
    totalCompletedOrders,
    createdAt,
    updatedAt,
  ];

  @override
  bool get stringify => true;
}
