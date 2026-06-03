import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart'; // For Position type
import 'package:rinsr_delivery_partner/core/services/bluetooth_scanner_service.dart';

import '../../../../core/services/location_service.dart';
import '../../../home/domain/entities/get_orders_entity.dart';
import '../../domain/entities/update_order_params.dart';
import '../../domain/usecases/cancel_order.dart';
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
  final LocationService locationService;
  StreamSubscription<Position>? _positionSubscription;
  StreamSubscription<List<int>>? _weightSubscription;
  StreamSubscription<BleScanFailure>? _weightFailureSubscription;
  final BluetoothScannerService bluetoothScannerService;

  OrderBloc({
    required this.updateOrder,
    required this.notifyUser,
    required this.markPaymentReceived,
    required this.cancelOrder,
    required this.locationService,
    required this.bluetoothScannerService,
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
    on<CancelOrderEvent>(_onCancelOrder);
    on<NotifyUserEvent>(_onNotifyUserEvent);
    on<StartWeightReading>(_onStartWeightReading);
    on<StopWeightReading>(_onStopWeightReading);
    on<LockWeightReading>(_onLockWeightReading);
    on<UnlockWeightReading>(_onUnlockWeightReading);
    on<WeightReadingUpdated>(_onWeightReadingUpdated);
    on<WeightScaleErrorEvent>(_onWeightScaleError);
  }

  void _listenWeightFailures() {
    _weightFailureSubscription ??= bluetoothScannerService.failures.listen((
      failure,
    ) {
      if (isClosed) return;
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

  Future<void> _onInitLocationEvent(
    InitLocationEvent event,
    Emitter<OrderState> emit,
  ) async {
    if (state is! OrderLoaded) return;
    final currentState = state as OrderLoaded;

    emit(currentState.copyWith(isLocationLoading: true, locationError: null));

    try {
      // 1. Check permissions (Assuming checked in main, but good to double check or handle stream)
      // 2. Get Target Address
      final targetLocation = await locationService.getCoordinatesFromAddress(
        event.targetAddress,
      );

      if (targetLocation == null) {
        emit(
          currentState.copyWith(
            isLocationLoading: false,
            locationError:
                'Could not find location for address: ${event.targetAddress}',
          ),
        );
        return;
      }

      // 3. Start Listening
      await _positionSubscription?.cancel();
      if (isClosed) return; // Check closure before starting new listener

      _positionSubscription = locationService.getPositionStream().listen(
        (position) {
          if (isClosed) return; // Check closure before adding event
          add(
            LocationUpdatedEvent(
              position: position,
              distance: locationService.getDistanceBetween(
                position.latitude,
                position.longitude,
                targetLocation.latitude,
                targetLocation.longitude,
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
        add(
          LocationUpdatedEvent(
            position: position,
            distance: locationService.getDistanceBetween(
              position.latitude,
              position.longitude,
              targetLocation.latitude,
              targetLocation.longitude,
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
