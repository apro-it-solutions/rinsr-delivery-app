import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'enums.dart';

enum DeliveryAgentStatus {
  accepted,
  pickup,
  transit,
  delivered,
  cancelled,
  unknown,
}

extension DeliveryAgentStatusExtension on DeliveryAgentStatus {
  String get label {
    switch (this) {
      case DeliveryAgentStatus.accepted:
        return 'Pending';
      case DeliveryAgentStatus.pickup:
        return 'Pickup';
      case DeliveryAgentStatus.transit:
        return 'On The Way';
      case DeliveryAgentStatus.delivered:
        return 'Delivered';
      case DeliveryAgentStatus.cancelled:
        return 'Cancelled';
      case DeliveryAgentStatus.unknown:
        return 'Unknown';
    }
  }

  Color get color {
    switch (this) {
      case DeliveryAgentStatus.accepted:
      case DeliveryAgentStatus.pickup:
      case DeliveryAgentStatus.transit:
        return AppColors.primary;
      case DeliveryAgentStatus.delivered:
        return Colors.green;
      case DeliveryAgentStatus.cancelled:
        return Colors.red;
      case DeliveryAgentStatus.unknown:
        return Colors.grey;
    }
  }

  Color get backgroundColor {
    return color.withValues(alpha: 0.1);
  }
}

extension OrderStatusExtension on OrderStatus {
  DeliveryAgentStatus get agentStatus {
    switch (this) {
      // PRE-PICKUP PHASE
      case OrderStatus.scheduled:
      case OrderStatus.readyToPickupFromHub:
      case OrderStatus.serviceCompleted:
        return DeliveryAgentStatus.accepted;

      // PICKUP PHASE
      // case OrderStatus.readyToPickupFromHub: // Removed from agent flow
      // case OrderStatus.serviceCompleted: // Removed from agent flow
      // case OrderStatus
      //     .readyToPickupFromHub: // Ready to pickup from hub (for delivery)
      //   return DeliveryAgentStatus.pickup;
      // TRANSIT PHASE
      case OrderStatus.pickedUp:
      // case OrderStatus.vendorPickedUp: // Removed from agent flow
      // case OrderStatus.vendorReturning: // Removed from agent flow
      case OrderStatus.outForDelivery:
        return DeliveryAgentStatus.transit;

      // RETURN-LEG READY PHASE
      // `ready` (backend: post-washing) marks the return pickup as available
      // and must surface as Pending so any eligible agent can accept it —
      // grouping it under "Delivered" hid return orders from every agent
      // except whoever did the forward leg.
      case OrderStatus.ready:
        return DeliveryAgentStatus.accepted;

      // DELIVERED/PROCESSING PHASE
      case OrderStatus.vendorPickedUp:
      case OrderStatus.vendorReturning:
      case OrderStatus.processing:
      case OrderStatus.washing:
      case OrderStatus.delivered:
        return DeliveryAgentStatus.delivered;

      case OrderStatus.cancelled:
        return DeliveryAgentStatus.cancelled;
    }
  }
}
