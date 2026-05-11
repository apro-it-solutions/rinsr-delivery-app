part of 'order_bloc.dart';

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
  final double? weight;
  final bool isWeightLocked;
  final bool isSubmitting;

  const OrderLoaded(
    this.order, {
    this.weight,
    this.isWeightLocked = false,
    this.currentLocation,
    this.distanceInMeters,
    this.locationError,
    this.isLocationLoading = false,
    this.isSubmitting = false,
  });

  @override
  List<Object?> get props => [
    order,
    currentLocation,
    distanceInMeters,
    locationError,
    isLocationLoading,
    weight,
    isWeightLocked,
    isSubmitting,
  ];

  OrderLoaded copyWith({
    OrderDetailsEntity? order,
    Position? currentLocation,
    double? distanceInMeters,
    String? locationError,
    bool? isLocationLoading,
    double? weight,
    bool? isWeightLocked,
    bool? isSubmitting,
  }) {
    return OrderLoaded(
      order ?? this.order,
      currentLocation: currentLocation ?? this.currentLocation,
      distanceInMeters: distanceInMeters ?? this.distanceInMeters,
      locationError: locationError ?? this.locationError,
      isLocationLoading: isLocationLoading ?? this.isLocationLoading,
      weight: weight ?? this.weight,
      isWeightLocked: isWeightLocked ?? this.isWeightLocked,
      isSubmitting: isSubmitting ?? this.isSubmitting,
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
