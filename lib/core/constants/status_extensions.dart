import 'package:flutter/material.dart';
import 'package:rinsr_delivery_partner/core/theme/app_colors.dart';
import 'enums.dart';

enum DeliveryAgentStatus { pickup, transit, delivered, cancelled, unknown }

extension DeliveryAgentStatusExtension on DeliveryAgentStatus {
  String get label {
    switch (this) {
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
      // PICKUP PHASE
      case OrderStatus.scheduled:
      case OrderStatus.readyToPickupFromHub:
      case OrderStatus.serviceCompleted: // Ready to pickup from vendor
      case OrderStatus.ready: // Ready to pickup from hub (for delivery)
        return DeliveryAgentStatus.pickup;

      // TRANSIT PHASE
      case OrderStatus.pickedUp:
      case OrderStatus.vendorPickedUp:
      case OrderStatus.vendorReturning:
      case OrderStatus.outForDelivery:
        return DeliveryAgentStatus.transit;

      // DELIVERED PHASE
      case OrderStatus.processing:
      case OrderStatus.washing:
      case OrderStatus.delivered:
        return DeliveryAgentStatus.delivered;

      case OrderStatus.cancelled:
        return DeliveryAgentStatus.cancelled;
    }
  }
}
