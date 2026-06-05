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
  // Set when the Bluetooth scale can't be reached (permission denied, BT off,
  // scale not found) so the pickup form can tell the agent why auto-reading is
  // blank instead of failing silently.
  final String? weightScaleError;
  // Pay-On-Delivery QR (client issues #9/#21): fetched once per order so the
  // delivery form can show a scannable payment code while Confirm Delivery
  // stays locked until payment_status flips to 'paid'.
  final PaymentQrResponseEntity? paymentQr;
  final bool isPaymentQrLoading;
  final String? paymentQrError;

  const OrderLoaded(
    this.order, {
    this.weight,
    this.isWeightLocked = false,
    this.currentLocation,
    this.distanceInMeters,
    this.locationError,
    this.isLocationLoading = false,
    this.isSubmitting = false,
    this.weightScaleError,
    this.paymentQr,
    this.isPaymentQrLoading = false,
    this.paymentQrError,
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
    weightScaleError,
    paymentQr,
    isPaymentQrLoading,
    paymentQrError,
  ];

  OrderLoaded copyWith({
    OrderDetailsEntity? order,
    Position? currentLocation,
    double? distanceInMeters,
    String? locationError,
    bool? isLocationLoading,
    double? weight,
    // Null-coalescing on `weight` means passing null can't reset it; this flag
    // forces the weight back to null so a fresh weighing starts clean.
    bool clearWeight = false,
    bool? isWeightLocked,
    bool? isSubmitting,
    String? weightScaleError,
    // weightScaleError is null-coalesced, so passing null can't clear it; this
    // flag forces it back to null once a reading succeeds.
    bool clearWeightScaleError = false,
    PaymentQrResponseEntity? paymentQr,
    bool? isPaymentQrLoading,
    String? paymentQrError,
    // paymentQrError is null-coalesced like weightScaleError; this flag forces
    // it back to null when a retry starts.
    bool clearPaymentQrError = false,
  }) {
    return OrderLoaded(
      order ?? this.order,
      currentLocation: currentLocation ?? this.currentLocation,
      distanceInMeters: distanceInMeters ?? this.distanceInMeters,
      locationError: locationError ?? this.locationError,
      isLocationLoading: isLocationLoading ?? this.isLocationLoading,
      weight: clearWeight ? null : (weight ?? this.weight),
      isWeightLocked: isWeightLocked ?? this.isWeightLocked,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      weightScaleError: clearWeightScaleError
          ? null
          : (weightScaleError ?? this.weightScaleError),
      paymentQr: paymentQr ?? this.paymentQr,
      isPaymentQrLoading: isPaymentQrLoading ?? this.isPaymentQrLoading,
      paymentQrError: clearPaymentQrError
          ? null
          : (paymentQrError ?? this.paymentQrError),
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
