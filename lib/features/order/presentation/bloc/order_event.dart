import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';

import '../../../home/domain/entities/get_orders_entity.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object> get props => [];
}

class OrderLoadEvent extends OrderEvent {
  final OrderDetailsEntity order;

  const OrderLoadEvent({required this.order});

  @override
  List<Object> get props => [order];
}

// Phase A Events
class ArrivedAtLocation extends OrderEvent {}

class SubmitPickupDetails extends OrderEvent {
  final String photoPath;

  const SubmitPickupDetails({required this.photoPath});

  @override
  List<Object> get props => [photoPath];
}

class ScanQrCode extends OrderEvent {} // Confirm Pickup

class ConfirmHubDrop extends OrderEvent {}

// Phase B Events
class ConfirmVendorPickup extends OrderEvent {} // Pickup from Hub for Vendor

class ConfirmVendorDrop extends OrderEvent {}

// Phase C Events
class ConfirmHubReturnPickup extends OrderEvent {} // Pickup from Vendor

class ConfirmHubReturnDrop extends OrderEvent {}

// Phase D Events
class StartDelivery extends OrderEvent {} // Pickup from Hub for User

class SubmitProofOfDelivery extends OrderEvent {
  final String photoPath;

  const SubmitProofOfDelivery({required this.photoPath});

  @override
  List<Object> get props => [photoPath];
}

class NotifyUserEvent extends OrderEvent {
  final String orderId;

  const NotifyUserEvent({required this.orderId});

  @override
  List<Object> get props => [orderId];
}

class InitLocationEvent extends OrderEvent {
  final String targetAddress;

  const InitLocationEvent({required this.targetAddress});

  @override
  List<Object> get props => [targetAddress];
}

class LocationUpdatedEvent extends OrderEvent {
  final Position position;
  final double distance;

  const LocationUpdatedEvent({required this.position, required this.distance});

  @override
  List<Object> get props => [position, distance];
}

class LocationErrorEvent extends OrderEvent {
  final String message;

  const LocationErrorEvent(this.message);

  @override
  List<Object> get props => [message];
}
