import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart'; // For Position type
import 'package:rinsr_delivery_partner/core/services/background_tracking_service.dart';
import 'package:rinsr_delivery_partner/core/services/bluetooth_scanner_service.dart';
import 'package:rinsr_delivery_partner/core/services/driver_tracking_service.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/shared_preferences_service.dart';
import '../../../../core/services/tracking_position_filter.dart';
import '../../../../core/services/tracking_throttle.dart';
import '../../../home/domain/entities/get_orders_entity.dart';
import '../../domain/entities/update_order_params.dart';
import '../../domain/entities/payment_qr_response_entity.dart';
import '../../domain/usecases/cancel_order.dart';
import '../../domain/usecases/get_payment_qr.dart';
import '../../domain/usecases/mark_payment_received.dart';
import '../../domain/usecases/notify_user.dart';
import '../../domain/usecases/update_order.dart';
part 'order_event.dart';
part 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final UpdateOrder updateOrder;
  final NotifyUser notifyUser;
  final MarkPaymentReceived markPaymentReceived;
  final CancelOrder cancelOrder;
  final GetPaymentQr getPaymentQr;
  final LocationService locationService;
  StreamSubscription<Position>? _positionSubscription;
  StreamSubscription<List<int>>? _weightSubscription;
  StreamSubscription<BleScanFailure?>? _weightFailureSubscription;
  final BluetoothScannerService bluetoothScannerService;
  final DriverTrackingService trackingService;
  final BackgroundTrackingService backgroundTrackingService;
  // Throttles the foreground-fallback tracking POSTs (same 5s policy the
  // background isolate applies via its own TrackingThrottle).
  final TrackingThrottle _trackingThrottle = TrackingThrottle();
  final TrackingPositionFilter _trackingFilter = TrackingPositionFilter();

  OrderBloc({
    required this.updateOrder,
    required this.notifyUser,
    required this.markPaymentReceived,
    required this.cancelOrder,
    required this.getPaymentQr,
    required this.locationService,
    required this.bluetoothScannerService,
    required this.trackingService,
    required this.backgroundTrackingService,
  }) : super(OrderInitial()) {
    on<OrderLoadEvent>(_onOrderLoadEvent);
    on<InitLocationEvent>(_onInitLocationEvent);
    on<LocationUpdatedEvent>(_onLocationUpdatedEvent);
    on<ArrivedAtLocation>(_onArrivedAtLocation);
    on<SubmitPickupDetails>(_onSubmitPickupDetails);
    on<ConfirmHubDrop>(_onConfirmHubDrop);
    on<ConfirmVendorPickup>(_onConfirmVendorPickup);
    on<ConfirmVendorDrop>(_onConfirmVendorDrop);
    on<ConfirmHubReturnPickup>(_onConfirmHubReturnPickup);
    on<ConfirmHubReturnDrop>(_onConfirmHubReturnDrop);
    on<StartDelivery>(_onStartDelivery);
    on<SubmitProofOfDelivery>(_onSubmitProofOfDelivery);
    on<MarkCashPaymentReceived>(_onMarkCashPaymentReceived);
    on<LoadPaymentQr>(_onLoadPaymentQr);
    on<CancelOrderEvent>(_onCancelOrder);
    on<NotifyUserEvent>(_onNotifyUserEvent);
    on<StartWeightReading>(_onStartWeightReading);
    on<StopWeightReading>(_onStopWeightReading);
    on<LockWeightReading>(_onLockWeightReading);
    on<UnlockWeightReading>(_onUnlockWeightReading);
    on<WeightReadingUpdated>(_onWeightReadingUpdated);
    on<WeightScaleErrorEvent>(_onWeightScaleError);
    on<WeightScaleErrorCleared>(_onWeightScaleErrorCleared);
  }

  @override
  void onChange(Change<OrderState> change) {
    super.onChange(change);
    final next = change.nextState;
    if (next is OrderLoaded) _syncBackgroundTracking(next.order);
  }

  /// Keeps background GPS tracking in lockstep with the order's en-route
  /// status instead of any screen's lifecycle, so it survives screen pops and
  /// app backgrounding. Runs on every state change — start/stop are
  /// idempotent and cheap when nothing changed.
  void _syncBackgroundTracking(OrderDetailsEntity order) {
    final orderId = order.orderId;
    if (orderId == null || orderId.isEmpty) return;
    final String? agentId;
    try {
      agentId = SharedPreferencesService.getString(AppConstants.kAgentId);
    } catch (_) {
      return; // Prefs not initialized (unit tests).
    }
    if (kDebugMode) {
      debugPrint(
        '[TRACKING] sync: orderId=$orderId agentId=$agentId '
        'status=${order.computedStatus} '
        'currentDP=${order.deliveryUpdates?.currentDeliveryPartnerId} '
        'postWashingLimbo=${order.isPostWashingLimbo} '
        'acceptedReturn=${agentId != null && order.hasAcceptedReturnLeg(agentId)} '
        'isActiveForAgent=${agentId != null && order.isActiveForAgent(agentId)} '
        'isEnRoute=${agentId != null && order.isEnRouteForAgent(agentId)} '
        'bgActive=${backgroundTrackingService.activeOrderId}',
      );
    }
    if (agentId != null && order.isEnRouteForAgent(agentId)) {
      backgroundTrackingService.start(
        orderId: orderId,
        orderLabel: order.displayOrderID != null
            ? '#RIN-${order.displayOrderID}'
            : null,
      );
    } else if (backgroundTrackingService.activeOrderId == orderId) {
      backgroundTrackingService.stop();
    }
  }

  void _listenWeightFailures() {
    _weightFailureSubscription ??= bluetoothScannerService.failures.listen((
      failure,
    ) {
      if (isClosed) return;
      if (failure == null) {
        // Scan recovered (e.g. the agent turned Bluetooth back on while
        // already on this screen) — clear the banner.
        add(const WeightScaleErrorCleared());
        return;
      }
      final message = switch (failure) {
        BleScanFailure.permissionDenied =>
          'Bluetooth permission denied. Enable "Nearby devices" in Settings, '
              'or enter the weight manually.',
        BleScanFailure.adapterOff =>
          'Bluetooth is off. Turn it on to auto-read the scale, '
              'or enter the weight manually.',
        BleScanFailure.error =>
          'Could not connect to the weight scale. '
              'Enter the weight manually.',
      };
      add(WeightScaleErrorEvent(message));
    });
  }

  void _onWeightScaleError(
    WeightScaleErrorEvent event,
    Emitter<OrderState> emit,
  ) {
    if (state is OrderLoaded) {
      emit((state as OrderLoaded).copyWith(weightScaleError: event.message));
    }
  }

  void _onWeightScaleErrorCleared(
    WeightScaleErrorCleared event,
    Emitter<OrderState> emit,
  ) {
    if (state is OrderLoaded) {
      emit((state as OrderLoaded).copyWith(clearWeightScaleError: true));
    }
  }

  // Phase A Handlers
  void _onArrivedAtLocation(ArrivedAtLocation event, Emitter<OrderState> emit) {
    // This event is now handled locally in the UI for the first step.
    // However, if we need to track it in backend, we would need a status for it.
    // Since backend doesn't support 'atLocation', we might not need to emit a new status here
    // unless we want to trigger a UI rebuild or save it locally.
    // For now, we'll leave it as a no-op or just emit current state if needed.
    // But the UI manages the step locally.
  }

  Future<void> _onSubmitPickupDetails(
    SubmitPickupDetails event,
    Emitter<OrderState> emit,
  ) async {
    if (state is OrderLoaded) {
      final currentLoaded = state as OrderLoaded;
      final currentOrder = currentLoaded.order;
      if (currentOrder.orderId != null) {
        emit(currentLoaded.copyWith(isSubmitting: true));
        final result = await updateOrder(
          UpdateOrderParams(
            orderId: currentOrder.orderId!,
            status: 'picked_up',
            photoPath: event.photoPath,
            weight: event.weight,
            barcode: event.barcode,
          ),
        );
        result.fold(
          (failure) {
            emit(currentLoaded.copyWith(isSubmitting: false));
            emit(const OrderError('Failed to update pickup details'));
          },
          (response) => emit(
            OrderUpdated(
              currentOrder.copyWith(
                status: 'picked_up',
                photoPath: event.photoPath,
              ),
            ),
          ),
        );
      }
    }
  }

  Future<void> _onConfirmHubDrop(
    ConfirmHubDrop event,
    Emitter<OrderState> emit,
  ) async {
    if (state is OrderLoaded) {
      final currentLoaded = state as OrderLoaded;
      final currentOrder = currentLoaded.order;
      if (currentOrder.orderId != null) {
        emit(currentLoaded.copyWith(isSubmitting: true));
        final result = await updateOrder(
          UpdateOrderParams(
            orderId: currentOrder.orderId!,
            status: 'processing',
          ),
        );
        result.fold(
          (failure) {
            emit(currentLoaded.copyWith(isSubmitting: false));
            emit(const OrderError('Failed to update status'));
          },
          (response) =>
              emit(OrderUpdated(currentOrder.copyWith(status: 'processing'))),
        );
      }
    }
  }

  // Phase B Handlers
  Future<void> _onConfirmVendorPickup(
    ConfirmVendorPickup event,
    Emitter<OrderState> emit,
  ) async {
    if (state is OrderLoaded) {
      final currentLoaded = state as OrderLoaded;
      final currentOrder = currentLoaded.order;
      if (currentOrder.orderId != null) {
        emit(currentLoaded.copyWith(isSubmitting: true));
        final result = await updateOrder(
          UpdateOrderParams(
            orderId: currentOrder.orderId!,
            status: 'vendor_picked_up',
          ),
        );
        result.fold(
          (failure) {
            emit(currentLoaded.copyWith(isSubmitting: false));
            emit(const OrderError('Failed to update status'));
          },
          (response) => emit(
            OrderUpdated(currentOrder.copyWith(status: 'vendor_picked_up')),
          ),
        );
      }
    }
  }

  Future<void> _onConfirmVendorDrop(
    ConfirmVendorDrop event,
    Emitter<OrderState> emit,
  ) async {
    if (state is OrderLoaded) {
      final currentLoaded = state as OrderLoaded;
      final currentOrder = currentLoaded.order;
      if (currentOrder.orderId != null) {
        emit(currentLoaded.copyWith(isSubmitting: true));
        final result = await updateOrder(
          UpdateOrderParams(orderId: currentOrder.orderId!, status: 'washing'),
        );
        result.fold(
          (failure) {
            emit(currentLoaded.copyWith(isSubmitting: false));
            emit(const OrderError('Failed to update status'));
          },
          (response) =>
              emit(OrderUpdated(currentOrder.copyWith(status: 'washing'))),
        );
      }
    }
  }

  // Phase C Handlers
  Future<void> _onConfirmHubReturnPickup(
    ConfirmHubReturnPickup event,
    Emitter<OrderState> emit,
  ) async {
    if (state is OrderLoaded) {
      final currentLoaded = state as OrderLoaded;
      final currentOrder = currentLoaded.order;
      if (currentOrder.orderId != null) {
        emit(currentLoaded.copyWith(isSubmitting: true));
        final result = await updateOrder(
          UpdateOrderParams(
            orderId: currentOrder.orderId!,
            status: 'vendor_returning',
          ),
        );
        result.fold(
          (failure) {
            emit(currentLoaded.copyWith(isSubmitting: false));
            emit(const OrderError('Failed to update status'));
          },
          (response) => emit(
            OrderUpdated(currentOrder.copyWith(status: 'vendor_returning')),
          ),
        );
      }
    }
  }

  Future<void> _onConfirmHubReturnDrop(
    ConfirmHubReturnDrop event,
    Emitter<OrderState> emit,
  ) async {
    if (state is OrderLoaded) {
      final currentLoaded = state as OrderLoaded;
      final currentOrder = currentLoaded.order;
      if (currentOrder.orderId != null) {
        emit(currentLoaded.copyWith(isSubmitting: true));
        final result = await updateOrder(
          UpdateOrderParams(
            orderId: currentOrder.orderId!,
            status: 'processing',
          ),
        );
        result.fold(
          (failure) {
            emit(currentLoaded.copyWith(isSubmitting: false));
            emit(const OrderError('Failed to update status'));
          },
          (response) =>
              emit(OrderUpdated(currentOrder.copyWith(status: 'processing'))),
        );
      }
    }
  }

  // Phase D Handlers
  Future<void> _onStartDelivery(
    StartDelivery event,
    Emitter<OrderState> emit,
  ) async {
    if (state is OrderLoaded) {
      final currentLoaded = state as OrderLoaded;
      final currentOrder = currentLoaded.order;
      if (currentOrder.orderId != null) {
        emit(currentLoaded.copyWith(isSubmitting: true));
        final result = await updateOrder(
          UpdateOrderParams(
            orderId: currentOrder.orderId!,
            status: 'out_for_delivery',
          ),
        );
        result.fold(
          (failure) {
            emit(currentLoaded.copyWith(isSubmitting: false));
            emit(const OrderError('Failed to update status'));
          },
          (response) => emit(
            OrderUpdated(currentOrder.copyWith(status: 'out_for_delivery')),
          ),
        );
      }
    }
  }

  Future<void> _onSubmitProofOfDelivery(
    SubmitProofOfDelivery event,
    Emitter<OrderState> emit,
  ) async {
    if (state is OrderLoaded) {
      final currentLoaded = state as OrderLoaded;
      final currentOrder = currentLoaded.order;
      if (currentOrder.orderId != null) {
        emit(currentLoaded.copyWith(isSubmitting: true));
        final result = await updateOrder(
          UpdateOrderParams(
            orderId: currentOrder.orderId!,
            status: 'delivered',
            photoPath: event.photoPath,
          ),
        );
        result.fold(
          (failure) {
            emit(currentLoaded.copyWith(isSubmitting: false));
            emit(const OrderError('Failed to update status'));
          },
          (response) => emit(
            OrderUpdated(
              currentOrder.copyWith(
                status: 'delivered',
                photoPath: event.photoPath,
              ),
            ),
          ),
        );
      }
    }
  }

  Future<void> _onMarkCashPaymentReceived(
    MarkCashPaymentReceived event,
    Emitter<OrderState> emit,
  ) async {
    if (state is OrderLoaded) {
      final currentLoaded = state as OrderLoaded;
      final currentOrder = currentLoaded.order;
      if (currentOrder.orderId != null) {
        emit(currentLoaded.copyWith(isSubmitting: true));
        final result = await markPaymentReceived(currentOrder.orderId!);
        result.fold(
          (failure) {
            emit(currentLoaded.copyWith(isSubmitting: false));
            emit(OrderError(failure.message));
          },
          (response) => emit(
            OrderLoaded(
              currentOrder.copyWith(
                paymentStatus: response.paymentStatus ?? 'paid',
              ),
              currentLocation: currentLoaded.currentLocation,
              distanceInMeters: currentLoaded.distanceInMeters,
              locationError: currentLoaded.locationError,
              isLocationLoading: currentLoaded.isLocationLoading,
              weight: currentLoaded.weight,
              isWeightLocked: currentLoaded.isWeightLocked,
              isSubmitting: false,
            ),
          ),
        );
      }
    }
  }

  Future<void> _onLoadPaymentQr(
    LoadPaymentQr event,
    Emitter<OrderState> emit,
  ) async {
    if (state is! OrderLoaded) return;
    final currentLoaded = state as OrderLoaded;
    final orderId = currentLoaded.order.orderId;
    if (orderId == null) return;
    // The QR for an order is stable; don't refetch on every rebuild/poll.
    if (currentLoaded.paymentQr != null && !event.forceRefresh) return;
    if (currentLoaded.isPaymentQrLoading) return;

    emit(
      currentLoaded.copyWith(
        isPaymentQrLoading: true,
        clearPaymentQrError: true,
      ),
    );
    final result = await getPaymentQr(orderId);
    if (state is! OrderLoaded) return;
    final latest = state as OrderLoaded;
    result.fold(
      (failure) => emit(
        latest.copyWith(
          isPaymentQrLoading: false,
          paymentQrError:
              'Could not load the payment QR. Retry, or collect cash.',
        ),
      ),
      (qr) => emit(
        latest.copyWith(isPaymentQrLoading: false, paymentQr: qr),
      ),
    );
  }

  Future<void> _onCancelOrder(
    CancelOrderEvent event,
    Emitter<OrderState> emit,
  ) async {
    if (state is OrderLoaded) {
      final currentLoaded = state as OrderLoaded;
      final currentOrder = currentLoaded.order;
      if (currentOrder.orderId != null) {
        emit(currentLoaded.copyWith(isSubmitting: true));
        final result = await cancelOrder(
          CancelOrderParams(
            orderId: currentOrder.orderId!,
            reason: event.reason,
          ),
        );
        result.fold(
          (failure) {
            emit(currentLoaded.copyWith(isSubmitting: false));
            emit(OrderError(failure.message));
          },
          (response) => emit(
            OrderUpdated(
              currentOrder.copyWith(
                status: 'cancelled',
                cancelReason: event.reason,
              ),
            ),
          ),
        );
      }
    }
  }

  FutureOr<void> _onOrderLoadEvent(
    OrderLoadEvent event,
    Emitter<OrderState> emit,
  ) {
    // Preserve already-computed location/distance state across refreshes.
    // Pull-to-refresh re-dispatches OrderLoadEvent with a fresh order entity;
    // emitting a bare OrderLoaded would reset distanceInMeters to null and make
    // the distance/ETA vanish until the next GPS tick (OR_22). The position
    // stream from InitLocationEvent stays subscribed, so keeping the prior
    // location fields shows continuous distance while the order data updates.
    final current = state;
    if (current is OrderLoaded) {
      emit(current.copyWith(order: event.order));
    } else {
      emit(OrderLoaded(event.order));
    }
  }

  FutureOr<void> _onNotifyUserEvent(
    NotifyUserEvent event,
    Emitter<OrderState> emit,
  ) async {
    if (state is OrderLoaded) {
      final currentOrder = (state as OrderLoaded).order;
      final result = await notifyUser(event.orderId);
      result.fold(
        (failure) => emit(const OrderError('Failed to notify user')),
        (response) => emit(OrderLoaded(currentOrder)),
      );
    }
  }

  /// Parses a backend "lat,lng" string; null when absent or malformed.
  (double, double)? _parseLatLng(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final parts = raw.split(',');
    if (parts.length != 2) return null;
    final lat = double.tryParse(parts[0].trim());
    final lng = double.tryParse(parts[1].trim());
    if (lat == null || lng == null) return null;
    return (lat, lng);
  }

  Future<void> _onInitLocationEvent(
    InitLocationEvent event,
    Emitter<OrderState> emit,
  ) async {
    if (state is! OrderLoaded) return;
    final currentState = state as OrderLoaded;

    emit(currentState.copyWith(isLocationLoading: true, locationError: null));

    try {
      // 1. Check permissions (Assuming checked in main, but good to double check or handle stream)
      // 2. Resolve the target. Prefer the backend's exact "lat,lng" — geocoding
      // the free-text address can land kilometres away (client report: a 130 m
      // pickup displayed as 24 mins because the address geocoded ~8 km off).
      double? targetLat;
      double? targetLng;
      final exact = _parseLatLng(event.targetCoordinates);
      if (exact != null) {
        targetLat = exact.$1;
        targetLng = exact.$2;
      } else {
        final geocoded = await locationService.getCoordinatesFromAddress(
          event.targetAddress,
        );
        targetLat = geocoded?.latitude;
        targetLng = geocoded?.longitude;
      }

      if (targetLat == null || targetLng == null) {
        emit(
          currentState.copyWith(
            isLocationLoading: false,
            locationError:
                'Could not find location for address: ${event.targetAddress}',
          ),
        );
        return;
      }
      // Promote to non-nullable locals for use inside the stream closure.
      final lat = targetLat;
      final lng = targetLng;

      // 3. Start Listening
      await _positionSubscription?.cancel();
      if (isClosed) return; // Check closure before starting new listener

      _positionSubscription = locationService.getPositionStream().listen(
        (position) {
          if (isClosed) return; // Check closure before adding event
          _postTracking(position);
          add(
            LocationUpdatedEvent(
              position: position,
              distance: locationService.getDistanceBetween(
                position.latitude,
                position.longitude,
                lat,
                lng,
              ),
            ),
          );
        },
        onError: (error) {
          // We might need a separate event to handle error from stream if we want to update state
        },
      );

      // Get initial position
      try {
        final position = await locationService.getCurrentPosition();
        if (isClosed) return; // Check closure before adding event
        _postTracking(position);
        add(
          LocationUpdatedEvent(
            position: position,
            distance: locationService.getDistanceBetween(
              position.latitude,
              position.longitude,
              lat,
              lng,
            ),
          ),
        );
      } catch (e) {
        // Ignore initial fetch error, stream should pick it up
      }
    } catch (e) {
      emit(
        currentState.copyWith(
          isLocationLoading: false,
          locationError: e.toString(),
        ),
      );
    }
  }

  void _onLocationUpdatedEvent(
    LocationUpdatedEvent event,
    Emitter<OrderState> emit,
  ) {
    if (state is OrderLoaded) {
      emit(
        (state as OrderLoaded).copyWith(
          currentLocation: event.position,
          distanceInMeters: event.distance,
          isLocationLoading: false,
        ),
      );
    }
  }

  /// Pushes the driver's position to the backend so the customer's tracking map
  /// can move the marker. Throttled to [_trackingInterval]; no-ops when there's
  /// no loaded order to attach the ping to. Fire-and-forget (errors swallowed
  /// inside the service) so it never blocks the location pipeline.
  void _postTracking(Position position) {
    // While the background service is active it owns the tracking POSTs
    // (and keeps them flowing with the app backgrounded); skip here so the
    // backend doesn't get double pings. This path remains the fallback when
    // background tracking is unavailable (permission denied, start failed).
    if (backgroundTrackingService.isActive) return;
    final current = state;
    final orderId = current is OrderLoaded ? current.order.orderId : null;
    if (orderId == null || orderId.isEmpty) return;

    final now = DateTime.now();
    if (!_trackingFilter.accept(position, now)) return;
    if (!_trackingThrottle.shouldPost(now)) return;

    trackingService.sendUpdate(
      orderId: orderId,
      lat: position.latitude,
      lng: position.longitude,
      headingDeg: position.heading >= 0 ? position.heading : null,
      speedKph: position.speed >= 0 ? position.speed * 3.6 : null,
    );
  }

  @override
  Future<void> close() {
    _positionSubscription?.cancel();
    _weightSubscription?.cancel();
    _weightFailureSubscription?.cancel();
    return super.close();
  }

  FutureOr<void> _onStartWeightReading(
    StartWeightReading event,
    Emitter<OrderState> emit,
  ) {
    // Begin every weighing session clean. The OrderBloc is shared for the whole
    // order flow, so a weight/lock left over from a previous item would stay on
    // screen and — because the live-reading listener is gated behind
    // `!isWeightLocked` — block any new readings from the scale.
    if (state is OrderLoaded) {
      emit(
        (state as OrderLoaded).copyWith(
          clearWeight: true,
          isWeightLocked: false,
          clearWeightScaleError: true,
        ),
      );
    }
    _listenWeightFailures();
    if (_weightSubscription == null) {
      bluetoothScannerService.startScan();
      _weightSubscription = bluetoothScannerService.stream.listen((data) {
        add(WeightReadingUpdated(weight: parseWeightKg(data)));
      });
    }
  }

  FutureOr<void> _onStopWeightReading(
    StopWeightReading event,
    Emitter<OrderState> emit,
  ) {
    _weightSubscription?.cancel();
    _weightSubscription = null;
    bluetoothScannerService.stopScan();
  }

  FutureOr<void> _onLockWeightReading(
    LockWeightReading event,
    Emitter<OrderState> emit,
  ) {
    if (state is OrderLoaded) {
      _weightSubscription?.cancel();
      _weightSubscription = null;
      bluetoothScannerService.stopScan();
      emit((state as OrderLoaded).copyWith(isWeightLocked: true));
    }
  }

  FutureOr<void> _onUnlockWeightReading(
    UnlockWeightReading event,
    Emitter<OrderState> emit,
  ) {
    if (state is OrderLoaded) {
      _listenWeightFailures();
      if (_weightSubscription == null) {
        bluetoothScannerService.startScan();
        _weightSubscription = bluetoothScannerService.stream.listen((data) {
          add(WeightReadingUpdated(weight: parseWeightKg(data)));
        });
      }
      emit((state as OrderLoaded).copyWith(isWeightLocked: false));
    }
  }

  FutureOr<void> _onWeightReadingUpdated(
    WeightReadingUpdated event,
    Emitter<OrderState> emit,
  ) {
    if (state is OrderLoaded) {
      // A live reading means the scale is reachable — clear any stale error.
      emit(
        (state as OrderLoaded).copyWith(
          weight: event.weight,
          clearWeightScaleError: true,
        ),
      );
    }
  }

  double parseWeightKg(List<int> bytes) {
    if (bytes.length < 12) return 0.0;
    final raw = (bytes[10] << 8) | bytes[11];
    return raw / 100.0;
  }
}
