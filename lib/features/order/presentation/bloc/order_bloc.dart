import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart'; // For Position type

import '../../../../core/services/location_service.dart';
import '../../domain/entities/update_order_params.dart';
import '../../domain/usecases/notify_user.dart';
import '../../domain/usecases/update_order.dart';
import 'order_event.dart';
import 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final UpdateOrder updateOrder;
  final NotifyUser notifyUser;
  final LocationService locationService;
  StreamSubscription<Position>? _positionSubscription;

  OrderBloc({
    required this.updateOrder,
    required this.notifyUser,
    required this.locationService,
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
    on<NotifyUserEvent>(_onNotifyUserEvent);
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
      final currentOrder = (state as OrderLoaded).order;
      if (currentOrder.orderId != null) {
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
          (failure) =>
              emit(const OrderError('Failed to update pickup details')),
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
      final currentOrder = (state as OrderLoaded).order;
      if (currentOrder.orderId != null) {
        final result = await updateOrder(
          UpdateOrderParams(
            orderId: currentOrder.orderId!,
            status: 'processing',
          ),
        );
        result.fold(
          (failure) => emit(const OrderError('Failed to update status')),
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
      final currentOrder = (state as OrderLoaded).order;
      if (currentOrder.orderId != null) {
        final result = await updateOrder(
          UpdateOrderParams(
            orderId: currentOrder.orderId!,
            status: 'vendor_picked_up',
          ),
        );
        result.fold(
          (failure) => emit(const OrderError('Failed to update status')),
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
      final currentOrder = (state as OrderLoaded).order;
      if (currentOrder.orderId != null) {
        final result = await updateOrder(
          UpdateOrderParams(orderId: currentOrder.orderId!, status: 'washing'),
        );
        result.fold(
          (failure) => emit(const OrderError('Failed to update status')),
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
      final currentOrder = (state as OrderLoaded).order;
      if (currentOrder.orderId != null) {
        final result = await updateOrder(
          UpdateOrderParams(
            orderId: currentOrder.orderId!,
            status: 'vendor_returning',
          ),
        );
        result.fold(
          (failure) => emit(const OrderError('Failed to update status')),
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
      final currentOrder = (state as OrderLoaded).order;
      if (currentOrder.orderId != null) {
        final result = await updateOrder(
          UpdateOrderParams(
            orderId: currentOrder.orderId!,
            status: 'processing',
          ),
        );
        result.fold(
          (failure) => emit(const OrderError('Failed to update status')),
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
      final currentOrder = (state as OrderLoaded).order;
      if (currentOrder.orderId != null) {
        final result = await updateOrder(
          UpdateOrderParams(
            orderId: currentOrder.orderId!,
            status: 'out_for_delivery',
          ),
        );
        result.fold(
          (failure) => emit(const OrderError('Failed to update status')),
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
      final currentOrder = (state as OrderLoaded).order;
      if (currentOrder.orderId != null) {
        final result = await updateOrder(
          UpdateOrderParams(
            orderId: currentOrder.orderId!,
            status: 'delivered',
            photoPath: event.photoPath,
          ),
        );
        result.fold(
          (failure) => emit(const OrderError('Failed to update status')),
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

  FutureOr<void> _onOrderLoadEvent(
    OrderLoadEvent event,
    Emitter<OrderState> emit,
  ) {
    emit(OrderLoaded(event.order));
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
    return super.close();
  }
}
