import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/models/get_orders_model/delivery_updates.dart';
import '../../domain/usecases/get_orders.dart';
import '../../../order/domain/entities/accept_order_response_entity.dart';

import '../../../../core/constants/enums.dart';
import '../../../../core/constants/status_extensions.dart';
import '../../../order/domain/entities/accept_order_params.dart';
import '../../../order/domain/usecases/accept_order.dart';
import '../../domain/entities/get_orders_entity.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetOrders getOrders;
  final AcceptOrder acceptOrder;
  HomeBloc({required this.getOrders, required this.acceptOrder})
    : super(HomeInitial()) {
    on<GetOrdersEvent>(_getOrders);
    on<FilterOrdersEvent>(_onFilterOrders);
    on<AcceptOrderEvent>(_onAcceptOrder);
  }

  FutureOr<void> _getOrders(
    GetOrdersEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    final result = await getOrders(const NoParams());
    result.fold((l) => emit(HomeError(message: l.message)), (r) {
      final userOrders =
          r.orders?.where((order) {
            // Only surface orders that a vendor has already accepted.
            // Until vendor_id is populated (and vendor_status leaves
            // 'awaiting_vendor'), the order isn't actionable for the
            // delivery partner and shouldn't appear in their list.
            final vendorAccepted =
                order.vendorId != null &&
                order.vendorStatus != 'awaiting_vendor';
            if (!vendorAccepted) return false;

            // The return leg has its own assignment slot. After washing, the
            // forward-leg agent's id stays in `pickedUpDeliveryPartnerId` and
            // `currentDeliveryPartnerId`, so a naive `pickedUpDeliveryPartnerId == null`
            // check hides every return-pickup order from every other agent.
            final status = order.computedStatus;

            // The vendor finished the service but hasn't dispatched yet — the
            // order is still sitting at the vendor and isn't collectable. Keep
            // it out of the list entirely until the vendor dispatches it.
            // (Bug: vendor marking the order `completed` surfaced it as a
            // "Pickup from Vendor" task before it was ready.)
            final isVendorPickupStage =
                status == OrderStatus.serviceCompleted ||
                status == OrderStatus.ready ||
                status == OrderStatus.readyToPickupFromHub;
            if (isVendorPickupStage && order.isAwaitingVendorDispatch) {
              return false;
            }

            // `ready` (post-washing) is the start of the return leg in the
            // production backend; the readyToPickupFromHub/outForDelivery
            // names cover the alternate mapping path.
            final isReturnLeg =
                status == OrderStatus.ready ||
                status == OrderStatus.readyToPickupFromHub ||
                status == OrderStatus.outForDelivery;

            final agentId = event.agentId;
            final updates = order.deliveryUpdates;
            final hasAcceptedReturn =
                updates?.delivered?.any(
                  (u) =>
                      u.deliveryId == agentId &&
                      u.status == 'accepted_for_return',
                ) ??
                false;

            final isUnassigned = isReturnLeg
                ? order.orderReturnedDeliveryPartner == null
                : order.pickedUpDeliveryPartnerId == null;
            final isPickedByMe =
                updates?.currentDeliveryPartnerId == agentId ||
                hasAcceptedReturn;
            return isUnassigned || isPickedByMe;
          }).toList() ??
          [];

      // Check if agent has an "On The Way" order (Transit status)
      // Since the list is already filtered to relevant orders, we just check status.
      final transitOrder = userOrders.where((order) {
        final status = order.computedStatus.agentStatus;
        return status == DeliveryAgentStatus.transit;
      }).firstOrNull;
      // Logic:
      // If there is an order in TRANSIT (On The Way), show ONLY that order.
      // Otherwise, show ALL orders (Assigned + Unassigned).
      if (transitOrder != null) {
        userOrders.retainWhere(
          (order) => order.orderId == transitOrder.orderId,
        );
      }

      emit(
        HomeLoaded(
          allOrders: userOrders,
          filteredOrders: userOrders,
          selectedFilter: DeliveryAgentStatus.accepted,
          agentId: event.agentId,
        ),
      );
    });
  }

  FutureOr<void> _onFilterOrders(
    FilterOrdersEvent event,
    Emitter<HomeState> emit,
  ) {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      final filter = event.filter;

      final filtered = currentState.allOrders.where((order) {
        // Basic filter matching
        final matchesStatus = order.computedStatus.agentStatus == filter;

        // Strict check for Delivered/Transit orders: must be assigned to THIS agent via deliveryUpdates
        if ((filter == DeliveryAgentStatus.delivered ||
                filter == DeliveryAgentStatus.transit) &&
            matchesStatus) {
          return order.deliveryUpdates?.currentDeliveryPartnerId ==
              currentState.agentId;
        }
        return matchesStatus;
      }).toList();
      emit(
        HomeLoaded(
          allOrders: currentState.allOrders,
          filteredOrders: filtered,
          selectedFilter: filter,
          agentId: currentState.agentId,
        ),
      );
    }
  }

  FutureOr<void> _onAcceptOrder(
    AcceptOrderEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;

      emit(HomeLoading());
      final result = await acceptOrder(event.params);
      result.fold((l) => emit(HomeError(message: l.message)), (r) {
        if (r.order != null) {
          final updatedOrders = List<OrderDetailsEntity>.from(
            currentState.allOrders,
          );
          final accept = r.order!;

          final index = updatedOrders.indexWhere((o) => o.orderId == r.orderId);
          if (index != -1) {
            // Merge the accept response into the existing list entry so
            // populated nested objects (userId.name/phone, hubId, pickupAddress,
            // serviceId, etc.) are preserved. The accept endpoint returns
            // user_id as a bare string, so blindly replacing would drop name
            // and phone, leaving the detail screen blank.
            final existing = updatedOrders[index];

            // Order.copyWith downcasts deliveryUpdates to the JSON model
            // subclass, so we must build that subclass (not the bare entity)
            // when forwarding the accept response.
            final acceptUpdates = accept.deliveryUpdates;
            final mergedUpdates = acceptUpdates == null
                ? existing.deliveryUpdates
                : DeliveryUpdates(
                    currentDeliveryPartnerId:
                        acceptUpdates.currentDeliveryPartnerId,
                    delivered: acceptUpdates.delivered
                        ?.map(
                          (e) => DeliveryUpdateItem(
                            status: e.status,
                            deliveryId: e.deliveryId,
                            timestamp: e.timestamp,
                            id: e.id,
                          ),
                        )
                        .toList(),
                    pickedUp: acceptUpdates.pickedUp
                        ?.map(
                          (e) => DeliveryUpdateItem(
                            status: e.status,
                            deliveryId: e.deliveryId,
                            timestamp: e.timestamp,
                            id: e.id,
                          ),
                        )
                        .toList(),
                  );

            updatedOrders[index] = existing.copyWith(
              status: accept.status,
              vendorStatus: accept.vendorStatus,
              paymentStatus: accept.paymentStatus,
              deliveryUpdates: mergedUpdates,
              pickedUpDeliveryPartnerId: accept.pickedUpDeliveryPartner
                  ?.toString(),
              // Hub / vendor may be newly assigned by the accept call.
              hubId: accept.hubId ?? existing.hubId,
              vendorId: accept.vendorId ?? existing.vendorId,
              updatedAt: accept.updatedAt,
              // Pricing / itemization may also be updated on accept.
              pricingType: accept.pricingType ?? existing.pricingType,
              services: accept.services ?? existing.services,
              selectedClothingItems:
                  accept.selectedClothingItems ?? existing.selectedClothingItems,
            );
          } else {
            updatedOrders.insert(0, OrderDetailsEntity.fromAcceptOrder(accept));
          }

          emit(HomeAcceptOrder(order: r));
          emit(
            HomeLoaded(
              allOrders: updatedOrders,
              filteredOrders:
                  updatedOrders, // Assuming filtering logic re-applies or we just refresh, but this is safer than stale
              selectedFilter: currentState.selectedFilter,
              agentId: currentState.agentId,
            ),
          );
        } else {
          // Fallback if order is missing in response
          emit(HomeAcceptOrder(order: r));
          emit(
            HomeLoaded(
              allOrders: currentState.allOrders,
              filteredOrders: currentState.filteredOrders,
              selectedFilter: currentState.selectedFilter,
              agentId: currentState.agentId,
            ),
          );
        }
      });
    }
  }
}
