import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rinsr_delivery_partner/core/utils/launcher_utils.dart';
import 'package:rinsr_delivery_partner/core/utils/app_alerts.dart';

import '../../../../core/constants/enums.dart';
import '../../../home/domain/entities/get_orders_entity.dart';
import '../../../home/presentation/home_router.dart';
import '../bloc/order_bloc.dart';
import '../bloc/order_event.dart';
import '../bloc/order_state.dart';
import '../widgets/order_completed_view.dart';
import '../widgets/order_delivery_form.dart';
import '../widgets/order_summary_card.dart';
import '../widgets/order_status_header.dart';
import '../widgets/order_location_status.dart';
import '../widgets/order_cancelled_view.dart';
import '../widgets/phase_views.dart';

class OrderDetailScreen extends StatefulWidget {
  final OrderDetailsEntity order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<OrderBloc>().add(OrderLoadEvent(order: widget.order));

    // Initialize location with target based on current status
    final targetAddress = _getTargetAddress(widget.order);
    if (targetAddress.isNotEmpty) {
      context.read<OrderBloc>().add(
        InitLocationEvent(targetAddress: targetAddress),
      );
    }
  }

  String _getTargetAddress(OrderDetailsEntity order) {
    switch (order.computedStatus) {
      // Phase A: User -> Hub
      case OrderStatus.scheduled:
        return order.userAddress; // Pickup from User
      case OrderStatus.pickedUp:
        return order.hubAddress; // Deliver to Hub

      // Phase B: Hub -> Vendor
      case OrderStatus.readyToPickupFromHub:
        return order.hubAddress; // Pickup from Hub
      case OrderStatus.vendorPickedUp:
        return order.vendorAddress; // Deliver to Vendor

      // Phase C: Vendor -> Hub
      case OrderStatus.serviceCompleted:
        return order.vendorAddress; // Pickup from Vendor
      case OrderStatus.vendorReturning:
        return order.hubAddress; // Deliver to Hub

      // Phase D: Hub -> User
      case OrderStatus.ready:
        return order.hubAddress; // Pickup from Hub (for delivery)
      case OrderStatus.outForDelivery:
        return order.userAddress; // Deliver to User

      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Order Details'),
      ),
      body: PopScope(
        canPop: false,
        child: BlocListener<OrderBloc, OrderState>(
          listener: (context, state) {
            if (state is OrderUpdated) {
              // If the order status updated, re-initialize location tracking for new target
              final newTarget = _getTargetAddress(state.order);
              if (newTarget.isNotEmpty) {
                context.read<OrderBloc>().add(
                  InitLocationEvent(targetAddress: newTarget),
                );
              }
              if (!mounted) return;
              Navigator.pushReplacementNamed(context, HomeRouter.home);
            }
            if (state is OrderError) {
              AppAlerts.showErrorSnackBar(
                context: context,
                message: state.message,
              );
            }
          },
          child: BlocBuilder<OrderBloc, OrderState>(
            builder: (context, state) {
              return _buildOrderContent(context, widget.order);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildOrderContent(BuildContext context, OrderDetailsEntity order) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OrderStatusHeader(status: order.computedStatus, type: order.type),
          const SizedBox(height: 16),
          OrderSummaryCard(order: order),
          const SizedBox(height: 16),
          if (order.computedStatus == OrderStatus.delivered)
            OrderCompletedView(order: order)
          else
            SingleChildScrollView(child: _buildActiveTaskView(context, order)),
        ],
      ),
    );
  }

  Widget _buildActiveTaskView(BuildContext context, OrderDetailsEntity order) {
    return BlocBuilder<OrderBloc, OrderState>(
      builder: (context, state) {
        final isLocationLoading = state is OrderLoaded
            ? state.isLocationLoading
            : true;
        final distanceInMeters = state is OrderLoaded
            ? state.distanceInMeters
            : null;
        final locationError = state is OrderLoaded ? state.locationError : null;
        final isEnabled = true;

        // distanceInMeters != null && distanceInMeters <= 50;

        final locationWidget = OrderLocationStatus(
          isLocationLoading: isLocationLoading,
          distanceInMeters: distanceInMeters,
          locationError: locationError,
          isEnabled: isEnabled,
        );

        switch (order.computedStatus) {
          case OrderStatus.scheduled:
          case OrderStatus.pickedUp:
            return PhaseAView(
              order: order,

              isEnabled: isEnabled,
              locationWidget: locationWidget,
              distance: distanceInMeters,
            );
          case OrderStatus.readyToPickupFromHub:
          case OrderStatus.vendorPickedUp:
          case OrderStatus.washing:
            return PhaseBView(
              order: order,
              isEnabled: isEnabled,
              locationWidget: locationWidget,
              distance: distanceInMeters,
            );
          case OrderStatus.serviceCompleted:
          case OrderStatus.vendorReturning:
            return PhaseCView(
              order: order,
              isEnabled: isEnabled,
              locationWidget: locationWidget,
              distance: distanceInMeters,
            );
          case OrderStatus.outForDelivery:
          case OrderStatus.delivered:
          case OrderStatus.ready:
            return PhaseDView(
              order: order,
              isEnabled: isEnabled,
              locationWidget: locationWidget,
              distance: distanceInMeters,
              deliveryForm: OrderDeliveryForm(
                order: order,
                onActionTap: () =>
                    LauncherUtils.launchMaps(context, order.userAddress),
              ),
            );
          case OrderStatus.processing:
            return OrderCompletedView(order: order);
          case OrderStatus.cancelled:
            return OrderCancelledView(order: order);
        }
      },
    );
  }
}
