import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_orders.dart';
import '../../../order/domain/entities/accept_order_response_entity.dart';

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
            final isUnassigned =
                order.pickedUpDeliveryPartnerId == null &&
                order.orderReturnedDeliveryPartner == null;
            final isPickedByMe =
                order.deliveryUpdates?.currentDeliveryPartnerId ==
                event.agentId;
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
        emit(HomeAcceptOrder(order: r));
        emit(
          HomeLoaded(
            allOrders: currentState.allOrders,
            filteredOrders: currentState.filteredOrders,
            selectedFilter: currentState.selectedFilter,
            agentId: currentState.agentId,
          ),
        );
      });
    }
  }
}
