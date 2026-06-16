import 'package:equatable/equatable.dart';
import '../../../../core/constants/enums.dart'; // Added import
import '../../../order/domain/entities/accept_order_response_entity.dart';

class GetOrdersEntity extends Equatable {
  final bool? success;
  final int? count;
  final List<OrderDetailsEntity>? orders;

  const GetOrdersEntity({this.success, this.count, this.orders});

  @override
  List<Object?> get props => [success, count, orders];
}

class OrderDetailsEntity extends Equatable {
  final PickupTimeSlotEntity? pickupTimeSlot;
  final PickupAddressEntity? pickupAddress;
  final List<String>? deliveryPartnerIds;
  final String? orderId;
  final int? displayOrderID;
  final UserIdEntity? userId;
  final DateTime? pickupDate;
  final ServiceIdEntity? serviceId;
  final double? distanceInKms;
  final dynamic addons;
  final String? totalWeightKg;
  final String? totalNoOfClothes;
  final String? heavyItems;
  final String? deliveryDate;
  final int? estimateTotalPrice;
  final int? basePrice;
  final int? addonPrice;
  final int? totalPrice;
  final String? status;
  final String? orderType;
  final String? bookingType;
  final String? paymentStatus;
  final String? paymentMethod;
  final String? vendorStatus;
  final DateTime? pickupNotificationAt;
  final bool? pickupNotificationSent;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;
  final HubIdEntity? hubId;
  final VendorDetailsEntity? vendorId;
  final SubscriptionSnapshotEntity? subscriptionSnapshot;
  final SubscriptionIdEntity? subscriptionId;
  final PlanIdEntity? planId;
  final String? photoPath; // Added for compatibility
  final String? cancelReason;
  final DeliveryUpdatesEntity? deliveryUpdates;
  final String? pickedUpDeliveryPartnerId;
  final String? orderReturnedDeliveryPartner;
  final String? barcode;
  final String? pricingType;
  final List<ServiceLineEntity>? services;
  final List<ServiceItemEntity>? selectedClothingItems;

  const OrderDetailsEntity({
    this.displayOrderID,
    this.pickupTimeSlot,
    this.pickupAddress,
    this.deliveryPartnerIds,
    this.orderId,
    this.userId,
    this.pickupDate,
    this.serviceId,
    this.addons,
    this.totalWeightKg,
    this.totalNoOfClothes,
    this.heavyItems,
    this.deliveryDate,
    this.estimateTotalPrice,
    this.basePrice,
    this.addonPrice,
    this.totalPrice,
    this.status,
    this.orderType,
    this.bookingType,
    this.paymentStatus,
    this.paymentMethod,
    this.vendorStatus,
    this.pickupNotificationAt,
    this.pickupNotificationSent,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.hubId,
    this.vendorId,
    this.subscriptionSnapshot,
    this.subscriptionId,
    this.planId,
    this.photoPath,
    this.cancelReason,
    this.deliveryUpdates,
    this.pickedUpDeliveryPartnerId,
    this.orderReturnedDeliveryPartner,
    this.barcode,
    this.pricingType,
    this.services,
    this.selectedClothingItems,
    this.distanceInKms,
  });

  // Rinsr Loop = subscription-based laundry; always weight-based regardless of
  // pricingType, since piece-count confirmation is not meaningful for these.
  bool get isSubscriptionOrder =>
      subscriptionSnapshot != null || subscriptionId != null;

  // Pay On Delivery: the agent collects payment at the doorstep (QR / cash)
  // before Confirm Delivery unlocks (client issues #9 / #21).
  //
  // The backend sends a cash-on-delivery code in `payment_method` (e.g. 'cod' /
  // 'cash'); prepaid/gateway orders come through as 'online'. Match any common
  // COD spelling case-insensitively so the QR/cash flow shows for all of them —
  // an earlier hardcoded 'pay_on_delivery' string never matched the real
  // payload, so the "Show Payment QR" button never rendered.
  static const Set<String> _payOnDeliveryMethods = {
    'cod',
    'cash',
    'cash_on_delivery',
    'cash-on-delivery',
    'pay_on_delivery',
    'pay-on-delivery',
    'pod',
  };

  bool get isPayOnDelivery =>
      _payOnDeliveryMethods.contains((paymentMethod ?? '').toLowerCase().trim());

  // "Book now" (immediate) vs "later" (scheduled) pickup. Book-now orders have
  // no meaningful pickup slot, so the scheduled-pickup summary is hidden for
  // them. Backend field: booking_type ('now' | 'later'). Treat unknown/missing
  // as scheduled so we never hide a real slot.
  bool get isBookNow => (bookingType ?? '').toLowerCase() == 'now';

  bool get isPaid => paymentStatus == 'paid';

  bool get isPerPiece => !isSubscriptionOrder && pricingType == 'per_piece';
  bool get isPerWeight =>
      isSubscriptionOrder ||
      pricingType == 'per_weight' ||
      pricingType == null;

  // Statuses where the agent is no longer actively involved with the order.
  // `ready` is intentionally NOT here: the order is sitting at the vendor
  // waiting for a return pickup, which is the next phase the agent can claim.
  bool get isTerminalForAgent {
    final s = computedStatus;
    return s == OrderStatus.cancelled ||
        s == OrderStatus.delivered ||
        s == OrderStatus.processing ||
        s == OrderStatus.washing;
  }

  // Post-washing limbo: the order sits at the hub/vendor (`ready` /
  // `readyToPickupFromHub`) with the forward-leg agent's id still lingering in
  // `currentDeliveryPartnerId`. That id alone doesn't mean they're busy — they
  // haven't accepted the return leg yet, so they're free to take other orders.
  //
  // `outForDelivery` is deliberately NOT here: an agent who is out for delivery
  // is physically driving the order to the customer (forward, return, or a
  // direct book-now leg that never has an `accepted_for_return` marker), so it
  // must always count as active.
  bool get isPostWashingLimbo {
    final s = computedStatus;
    return s == OrderStatus.ready || s == OrderStatus.readyToPickupFromHub;
  }

  // The vendor app moves an order washing → completed → dispatched. The agent
  // must only be allowed to collect the cleaned order from the vendor once it
  // has been DISPATCHED — `completed` just means washing is finished, not that
  // it's ready for pickup. (Bug: vendor marking `completed` wrongly surfaced
  // the "Pickup from Vendor" screen.)
  //
  // We block only when the vendor explicitly reports a pre-dispatch state, so
  // orders where the backend doesn't populate `vendor_status` are unaffected.
  static const _preDispatchVendorStatuses = {
    'awaiting_vendor',
    'new_order',
    'received',
    'accepted',
    'washing',
    'completed',
    'service_completed',
  };

  bool get isAwaitingVendorDispatch {
    final vs = vendorStatus?.toLowerCase();
    if (vs == null || vs.isEmpty) return false;
    return _preDispatchVendorStatuses.contains(vs);
  }

  bool hasAcceptedReturnLeg(String agentId) {
    return deliveryUpdates?.delivered?.any(
          (u) =>
              u.deliveryId == agentId && u.status == 'accepted_for_return',
        ) ??
        false;
  }

  // True if [agentId] is currently the assigned delivery partner and the
  // order is still in-progress (not terminal). Used to block accepting new
  // orders while one is already in flight.
  //
  // On the return leg, the forward-leg agent's id can linger in
  // `currentDeliveryPartnerId` after washing. We don't want that to block
  // them from accepting unrelated forward-leg orders, so the return leg
  // only counts as active once they've explicitly accepted the return.
  bool isActiveForAgent(String agentId) {
    if (deliveryUpdates?.currentDeliveryPartnerId != agentId) return false;
    if (isTerminalForAgent) return false;
    if (isPostWashingLimbo && !hasAcceptedReturnLeg(agentId)) return false;
    return true;
  }

  // En route = the agent is on a delivery leg whose destination is the
  // CUSTOMER, which is when the customer's live map matters:
  //   - scheduled            → heading out for the pickup (after accepting)
  //   - readyToPickupFromHub → collecting the clean order from the hub to
  //                            bring it to the customer (same PhaseDView /
  //                            distance-to-customer as out-for-delivery)
  //   - outForDelivery       → final hop to the customer
  // All three render PhaseDView (or the pickup phase) and stream the agent's
  // position to the customer endpoint, so background GPS must stay on for them.
  bool isEnRouteForAgent(String agentId) {
    final s = computedStatus;
    if (s != OrderStatus.scheduled &&
        s != OrderStatus.outForDelivery &&
        s != OrderStatus.readyToPickupFromHub) {
      return false;
    }
    // Tracking follows the agent's physical movement to the customer, NOT the
    // accept-gate. Deliberately bypass isActiveForAgent's
    // `isPostWashingLimbo && !hasAcceptedReturnLeg` guard: on a return leg whose
    // backend payload lacks the `accepted_for_return` marker, that guard would
    // silently keep background tracking off (only the foreground stream posts —
    // "it updates when I reopen the app"). For tracking we only need: this agent
    // owns the order and it isn't terminal. (isActiveForAgent stays as-is for
    // the OR_13 accept-gate, which is a separate concern.)
    return deliveryUpdates?.currentDeliveryPartnerId == agentId &&
        !isTerminalForAgent;
  }

  int get aggregatePieceCount {
    if (services != null && services!.isNotEmpty) {
      return services!.fold<int>(
        0,
        (sum, s) =>
            sum +
            (s.items?.fold<int>(0, (s2, i) => s2 + (i.quantity ?? 0)) ?? 0),
      );
    }
    if (selectedClothingItems != null) {
      return selectedClothingItems!.fold<int>(
        0,
        (sum, i) => sum + (i.quantity ?? 0),
      );
    }
    final parsed = int.tryParse(totalNoOfClothes ?? '');
    return parsed ?? 0;
  }

  @override
  List<Object?> get props => [
    pickupTimeSlot,
    pickupAddress,
    deliveryPartnerIds,
    orderId,
    userId,
    pickupDate,
    serviceId,
    addons,
    totalWeightKg,
    totalNoOfClothes,
    heavyItems,
    deliveryDate,
    estimateTotalPrice,
    basePrice,
    addonPrice,
    totalPrice,
    status,
    orderType,
    bookingType,
    paymentStatus,
    paymentMethod,
    vendorStatus,
    pickupNotificationAt,
    pickupNotificationSent,
    createdAt,
    updatedAt,
    v,
    hubId,
    vendorId,
    subscriptionSnapshot,
    subscriptionId,
    planId,
    photoPath,
    cancelReason,
    barcode,
    pricingType,
    services,
    selectedClothingItems,
  ];

  // Getters to maintain compatibility with UI
  OrderStatus get computedStatus {
    if (status == null) return OrderStatus.scheduled;
    try {
      // Convert backend status string (e.g. 'picked_up') to camelCase enum (e.g. pickedUp)
      // Or if backend sends 'scheduled', 'picked_up', etc.
      // We need to map them correctly.
      // The backend values are: 'scheduled', 'picked_up', 'processing', 'vendor_picked_up',
      // 'service_completed', 'vendor_returning', 'ready', 'ready_to_pickup_from_hub',
      // 'out_for_delivery', 'delivered', 'cancelled'

      switch (status) {
        case 'scheduled':
          return OrderStatus.scheduled;
        case 'picked_up':
          return OrderStatus.pickedUp;
        case 'processing':
          return OrderStatus.processing;
        case 'vendor_picked_up':
          return OrderStatus.vendorPickedUp;
        case 'service_completed':
          return OrderStatus.serviceCompleted;
        case 'vendor_returning':
          return OrderStatus.vendorReturning;
        case 'ready':
          return OrderStatus.ready;
        case 'washing':
          return OrderStatus.washing;
        case 'ready_to_pickup_from_vendor':
          return OrderStatus.readyToPickupFromHub;
        case 'out_for_delivery':
          return OrderStatus.outForDelivery;
        case 'delivered':
          return OrderStatus.delivered;
        case 'cancelled':
          return OrderStatus.cancelled;
        default:
          return OrderStatus.scheduled;
      }
    } catch (_) {
      return OrderStatus.scheduled;
    }
  }

  TaskType get type {
    if (orderType == null) return TaskType.pickupFromUser;
    try {
      return TaskType.values.firstWhere(
        (e) => e.toString().split('.').last == orderType,
        orElse: () => TaskType.pickupFromUser,
      );
    } catch (_) {
      return TaskType.pickupFromUser;
    }
  }

  String get userAddress => pickupAddress?.addressLine ?? '';
  String get hubAddress => vendorId?.location ?? '';
  String get vendorAddress => vendorId?.location ?? '';

  /// Exact "lat,lng" of the current navigation target, mirroring the
  /// `_getTargetAddress` switches in the UI (user for pickup/delivery legs,
  /// hub/vendor otherwise). Null when the backend didn't send coordinates —
  /// callers then fall back to geocoding the address text.
  String? get navTargetCoordinates {
    switch (computedStatus) {
      case OrderStatus.scheduled:
      case OrderStatus.outForDelivery:
        return pickupAddress?.coordinates; // user address
      case OrderStatus.pickedUp:
      case OrderStatus.ready:
      case OrderStatus.readyToPickupFromHub:
      case OrderStatus.vendorReturning:
      case OrderStatus.serviceCompleted:
        return vendorId?.locationCoordinates; // hub/vendor address
      default:
        return null;
    }
  }
  String get userName => userId?.name ?? '';
  String get userPhone => userId?.phone ?? '';
  String get vendorName => vendorId?.companyName ?? '';
  double get estimatedEarnings =>
      (estimateTotalPrice ?? 0).toDouble(); // Mock logic

  OrderDetailsEntity copyWith({
    PickupTimeSlotEntity? pickupTimeSlot,
    PickupAddressEntity? pickupAddress,
    List<String>? deliveryPartnerIds,
    String? orderId,
    UserIdEntity? userId,
    DateTime? pickupDate,
    ServiceIdEntity? serviceId,
    dynamic addons,
    String? totalWeightKg,
    String? totalNoOfClothes,
    String? heavyItems,
    String? deliveryDate,
    int? estimateTotalPrice,
    int? basePrice,
    int? addonPrice,
    int? totalPrice,
    String? status,
    String? orderType,
    String? paymentStatus,
    String? paymentMethod,
    String? vendorStatus,
    DateTime? pickupNotificationAt,
    bool? pickupNotificationSent,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? v,
    HubIdEntity? hubId,
    VendorDetailsEntity? vendorId,
    SubscriptionSnapshotEntity? subscriptionSnapshot,
    SubscriptionIdEntity? subscriptionId,
    PlanIdEntity? planId,
    String? photoPath,
    String? cancelReason,
    int? displayOrderID,
    DeliveryUpdatesEntity? deliveryUpdates,
    String? pickedUpDeliveryPartnerId,
    String? orderReturnedDeliveryPartner,
    String? barcode,
    String? pricingType,
    List<ServiceLineEntity>? services,
    List<ServiceItemEntity>? selectedClothingItems,
  }) {
    return OrderDetailsEntity(
      pickupTimeSlot: pickupTimeSlot ?? this.pickupTimeSlot,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      deliveryPartnerIds: deliveryPartnerIds ?? this.deliveryPartnerIds,
      orderId: orderId ?? this.orderId,
      userId: userId ?? this.userId,
      pickupDate: pickupDate ?? this.pickupDate,
      serviceId: serviceId ?? this.serviceId,
      addons: addons ?? this.addons,
      totalWeightKg: totalWeightKg ?? this.totalWeightKg,
      totalNoOfClothes: totalNoOfClothes ?? this.totalNoOfClothes,
      heavyItems: heavyItems ?? this.heavyItems,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      estimateTotalPrice: estimateTotalPrice ?? this.estimateTotalPrice,
      basePrice: basePrice ?? this.basePrice,
      addonPrice: addonPrice ?? this.addonPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      orderType: orderType ?? this.orderType,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      vendorStatus: vendorStatus ?? this.vendorStatus,
      pickupNotificationAt: pickupNotificationAt ?? this.pickupNotificationAt,
      pickupNotificationSent:
          pickupNotificationSent ?? this.pickupNotificationSent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      v: v ?? this.v,
      hubId: hubId ?? this.hubId,
      vendorId: vendorId ?? this.vendorId,
      subscriptionSnapshot: subscriptionSnapshot ?? this.subscriptionSnapshot,
      subscriptionId: subscriptionId ?? this.subscriptionId,
      planId: planId ?? this.planId,
      photoPath: photoPath ?? this.photoPath,
      cancelReason: cancelReason ?? this.cancelReason,
      displayOrderID: displayOrderID ?? this.displayOrderID,
      deliveryUpdates: deliveryUpdates ?? this.deliveryUpdates,
      pickedUpDeliveryPartnerId:
          pickedUpDeliveryPartnerId ?? this.pickedUpDeliveryPartnerId,
      orderReturnedDeliveryPartner:
          orderReturnedDeliveryPartner ?? this.orderReturnedDeliveryPartner,
      barcode: barcode ?? this.barcode,
      pricingType: pricingType ?? this.pricingType,
      services: services ?? this.services,
      selectedClothingItems:
          selectedClothingItems ?? this.selectedClothingItems,
    );
  }

  factory OrderDetailsEntity.fromAcceptOrder(
    AcceptOrderDetailsEntity acceptOrder, {
    int? displayOrderID,
  }) {
    return OrderDetailsEntity(
      displayOrderID: displayOrderID,
      pickupTimeSlot: acceptOrder.pickupTimeSlot,
      pickupAddress: acceptOrder.pickupAddress,
      deliveryPartnerIds: acceptOrder.deliveryPartnerIds
          ?.map((e) => e.toString())
          .toList(),
      orderId: acceptOrder.orderId,
      userId: acceptOrder.userId != null
          ? UserIdEntity(id: acceptOrder.userId)
          : null, // Basic mapping as userId is String in acceptOrder
      pickupDate: acceptOrder.pickupDate,
      serviceId: acceptOrder.serviceId,
      addons: acceptOrder.addons,
      totalWeightKg: acceptOrder.totalWeightKg,
      totalNoOfClothes: acceptOrder.totalNoOfClothes,
      heavyItems: acceptOrder.heavyItems,
      deliveryDate: acceptOrder.deliveryDate,
      estimateTotalPrice: acceptOrder.estimateTotalPrice,
      basePrice: acceptOrder.basePrice,
      addonPrice: acceptOrder.addonPrice,
      totalPrice: acceptOrder.totalPrice,
      status: acceptOrder.status,
      orderType: acceptOrder.orderType,
      paymentStatus: acceptOrder.paymentStatus,
      paymentMethod: acceptOrder.paymentMethod,
      vendorStatus: acceptOrder.vendorStatus,
      pickupNotificationSent: acceptOrder.pickupNotificationSent,
      createdAt: acceptOrder.createdAt,
      updatedAt: acceptOrder.updatedAt,
      v: acceptOrder.v,
      hubId: acceptOrder.hubId,
      vendorId: acceptOrder.vendorId,
      subscriptionSnapshot: acceptOrder.subscriptionSnapshot,
      subscriptionId: acceptOrder.subscriptionId != null
          ? SubscriptionIdEntity(id: acceptOrder.subscriptionId)
          : null,
      planId: acceptOrder.planId != null
          ? PlanIdEntity(id: acceptOrder.planId)
          : null,
      deliveryUpdates: acceptOrder.deliveryUpdates != null
          ? DeliveryUpdatesEntity(
              currentDeliveryPartnerId:
                  acceptOrder.deliveryUpdates!.currentDeliveryPartnerId,
              delivered: acceptOrder.deliveryUpdates!.delivered
                  ?.map(
                    (e) => DeliveryUpdateItemEntity(
                      status: e.status,
                      deliveryId: e.deliveryId,
                      timestamp: e.timestamp,
                      id: e.id,
                    ),
                  )
                  .toList()
                  .cast<DeliveryUpdateItemEntity>(),
              pickedUp: acceptOrder.deliveryUpdates!.pickedUp
                  ?.map(
                    (e) => DeliveryUpdateItemEntity(
                      status: e.status,
                      deliveryId: e.deliveryId,
                      timestamp: e.timestamp,
                      id: e.id,
                    ),
                  )
                  .toList(),
            )
          : null,
      pickedUpDeliveryPartnerId: acceptOrder.pickedUpDeliveryPartner
          ?.toString(),
      pricingType: acceptOrder.pricingType,
      services: acceptOrder.services,
      selectedClothingItems: acceptOrder.selectedClothingItems,
    );
  }
}

class DeliveryUpdatesEntity extends Equatable {
  final String? currentDeliveryPartnerId;
  final List<DeliveryUpdateItemEntity>? delivered;
  final List<DeliveryUpdateItemEntity>? pickedUp;

  const DeliveryUpdatesEntity({
    this.currentDeliveryPartnerId,
    this.delivered,
    this.pickedUp,
  });

  @override
  List<Object?> get props => [currentDeliveryPartnerId, delivered, pickedUp];
}

class DeliveryUpdateItemEntity extends Equatable {
  final String? status;
  final String? deliveryId;
  final DateTime? timestamp;
  final String? id;

  const DeliveryUpdateItemEntity({
    this.status,
    this.deliveryId,
    this.timestamp,
    this.id,
  });

  @override
  List<Object?> get props => [status, deliveryId, timestamp, id];
}

class PickupTimeSlotEntity extends Equatable {
  final String? startTime;
  final String? endTime;

  const PickupTimeSlotEntity({this.startTime, this.endTime});

  @override
  List<Object?> get props => [startTime, endTime];
}

class PickupAddressEntity extends Equatable {
  final String? label;
  final String? addressLine;

  /// Exact GPS position of the address as "lat,lng" (captured by the user
  /// app). Prefer this over geocoding [addressLine], which can resolve
  /// kilometres away for free-text Indian addresses.
  final String? coordinates;

  const PickupAddressEntity({this.label, this.addressLine, this.coordinates});

  @override
  List<Object?> get props => [label, addressLine, coordinates];
}

class UserIdEntity extends Equatable {
  final String? id;
  final String? name;
  final String? phone;
  final String? email;
  final String? loginMethod;
  final bool? isVerified;
  final bool? phoneVerified;
  final bool? emailVerified;
  final int? tokenVersion;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;
  final dynamic profileImage;
  final List<String>? deviceTokens;

  const UserIdEntity({
    this.id,
    this.name,
    this.phone,
    this.email,
    this.loginMethod,
    this.isVerified,
    this.phoneVerified,
    this.emailVerified,
    this.tokenVersion,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.profileImage,
    this.deviceTokens,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    phone,
    email,
    loginMethod,
    isVerified,
    phoneVerified,
    emailVerified,
    tokenVersion,
    createdAt,
    updatedAt,
    v,
    profileImage,
    deviceTokens,
  ];
}

class ServiceIdEntity extends Equatable {
  final String? id;
  final String? name;
  final int? price;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  const ServiceIdEntity({
    this.id,
    this.name,
    this.price,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  @override
  List<Object?> get props => [id, name, price, createdAt, updatedAt, v];
}

class ServiceEntity extends Equatable {
  final String? serviceId;
  final String? name;
  final String? id;

  const ServiceEntity({this.serviceId, this.name, this.id});

  @override
  List<Object?> get props => [serviceId, name, id];
}

class HubIdEntity extends Equatable {
  final String? hubId;
  final String? name;
  final String? location;
  final String? locationCoordinates;
  final String? primaryContact;
  final String? secondaryContact;
  final List<String>? vendorIds;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<String>? deliveryPartnerIds;

  const HubIdEntity({
    this.hubId,
    this.name,
    this.location,
    this.locationCoordinates,
    this.primaryContact,
    this.secondaryContact,
    this.vendorIds,
    this.createdAt,
    this.updatedAt,
    this.deliveryPartnerIds,
  });

  @override
  List<Object?> get props => [
    hubId,
    name,
    location,
    locationCoordinates,
    primaryContact,
    secondaryContact,
    vendorIds,
    createdAt,
    updatedAt,
    deliveryPartnerIds,
  ];
}

class VendorDetailsEntity extends Equatable {
  final String? id;
  final String? companyName;
  final String? location;
  final String? locationCoordinates;
  final String? phoneNumber;
  final List<String>? deviceTokens;
  final List<VendorServiceEntity>? services;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  const VendorDetailsEntity({
    this.id,
    this.companyName,
    this.location,
    this.locationCoordinates,
    this.phoneNumber,
    this.deviceTokens,
    this.services,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  @override
  List<Object?> get props => [
    id,
    companyName,
    location,
    locationCoordinates,
    phoneNumber,
    deviceTokens,
    services,
    isActive,
    createdAt,
    updatedAt,
    v,
  ];
}

class SubscriptionSnapshotEntity extends Equatable {
  final String? planName;
  final int? remainingBags;
  final DateTime? nextRenewalDate;

  const SubscriptionSnapshotEntity({
    this.planName,
    this.remainingBags,
    this.nextRenewalDate,
  });

  @override
  List<Object?> get props => [planName, remainingBags, nextRenewalDate];
}

class SubscriptionIdEntity extends Equatable {
  final String? id;
  final String? userId;
  final String? planId;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? status;
  final int? usedWeightKg;
  final int? usedPickups;
  final bool? autoRenew;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  const SubscriptionIdEntity({
    this.id,
    this.userId,
    this.planId,
    this.startDate,
    this.endDate,
    this.status,
    this.usedWeightKg,
    this.usedPickups,
    this.autoRenew,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    planId,
    startDate,
    endDate,
    status,
    usedWeightKg,
    usedPickups,
    autoRenew,
    createdAt,
    updatedAt,
    v,
  ];
}

class PlanIdEntity extends Equatable {
  final String? id;
  final String? name;
  final String? description;
  final int? price;
  final String? currency;
  final int? validityDays;
  final int? weightLimitKg;
  final int? pickupsPerMonth;
  final List<String>? features;
  final List<ServiceEntity>? services;
  final int? extraKgRate;
  final int? rolloverLimitMonths;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  const PlanIdEntity({
    this.id,
    this.name,
    this.description,
    this.price,
    this.currency,
    this.validityDays,
    this.weightLimitKg,
    this.pickupsPerMonth,
    this.features,
    this.services,
    this.extraKgRate,
    this.rolloverLimitMonths,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    price,
    currency,
    validityDays,
    weightLimitKg,
    pickupsPerMonth,
    features,
    services,
    extraKgRate,
    rolloverLimitMonths,
    isActive,
    createdAt,
    updatedAt,
    v,
  ];
}

class VendorServiceEntity extends Equatable {
  final String? name;
  final num? price;

  const VendorServiceEntity({this.name, this.price});

  @override
  List<Object?> get props => [name, price];
}

class ServiceLineEntity extends Equatable {
  final String? serviceId;
  final String? serviceName;
  final List<ServiceItemEntity>? items;
  final num? subtotal;
  final String? id;

  const ServiceLineEntity({
    this.serviceId,
    this.serviceName,
    this.items,
    this.subtotal,
    this.id,
  });

  @override
  List<Object?> get props => [serviceId, serviceName, items, subtotal, id];
}

class ServiceItemEntity extends Equatable {
  final String? categoryId;
  final String? categoryName;
  final String? itemId;
  final String? itemName;
  final num? pricePerPiece;
  final num? pricePerWeight;
  final num? avgWeightPerPiece;
  final int? quantity;
  final num? estimatedWeight;
  final num? lineTotal;
  final String? id;

  const ServiceItemEntity({
    this.categoryId,
    this.categoryName,
    this.itemId,
    this.itemName,
    this.pricePerPiece,
    this.pricePerWeight,
    this.avgWeightPerPiece,
    this.quantity,
    this.estimatedWeight,
    this.lineTotal,
    this.id,
  });

  num get computedLineTotal {
    if (lineTotal != null) return lineTotal!;
    if (pricePerPiece != null && quantity != null) {
      return pricePerPiece! * quantity!;
    }
    return 0;
  }

  @override
  List<Object?> get props => [
    categoryId,
    categoryName,
    itemId,
    itemName,
    pricePerPiece,
    pricePerWeight,
    avgWeightPerPiece,
    quantity,
    estimatedWeight,
    lineTotal,
    id,
  ];
}
