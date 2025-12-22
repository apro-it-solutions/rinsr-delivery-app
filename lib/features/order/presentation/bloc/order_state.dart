import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import '../../../home/domain/entities/get_orders_entity.dart';

abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrderLoaded extends OrderState {
  final OrderDetailsEntity order;
  // Location State
  final Position? currentLocation;
  final double? distanceInMeters;
  final String? locationError;
  final bool isLocationLoading;

  const OrderLoaded(
    this.order, {
    this.currentLocation,
    this.distanceInMeters,
    this.locationError,
    this.isLocationLoading = false,
  });

  @override
  List<Object?> get props => [
    order,
    currentLocation,
    distanceInMeters,
    locationError,
    isLocationLoading,
  ];

  OrderLoaded copyWith({
    OrderDetailsEntity? order,
    Position? currentLocation,
    double? distanceInMeters,
    String? locationError,
    bool? isLocationLoading,
  }) {
    return OrderLoaded(
      order ?? this.order,
      currentLocation: currentLocation ?? this.currentLocation,
      distanceInMeters: distanceInMeters ?? this.distanceInMeters,
      locationError: locationError ?? this.locationError,
      isLocationLoading: isLocationLoading ?? this.isLocationLoading,
    );
  }
}

class OrderError extends OrderState {
  final String message;

  const OrderError(this.message);

  @override
  List<Object> get props => [message];
}

class OrderUpdated extends OrderLoaded {
  const OrderUpdated(super.order);
}
