import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/enums.dart';
import '../../../../core/utils/app_alerts.dart';
import '../../../../core/utils/launcher_utils.dart';
import '../../../home/domain/entities/get_orders_entity.dart';
import '../bloc/order_bloc.dart';
import '../bloc/order_event.dart';
import '../widgets/order_completed_view.dart';
import '../widgets/order_info_card.dart';
import '../widgets/order_navigation_step.dart';
import '../widgets/order_pickup_form.dart';
import '../widgets/order_alert_banner.dart';
// import 'order_scan_qr_step.dart';

class PhaseAView extends StatefulWidget {
  final OrderDetailsEntity order;

  final bool isEnabled;
  final Widget locationWidget;
  final double? distance;

  const PhaseAView({
    super.key,
    required this.order,
    required this.isEnabled,
    required this.locationWidget,
    this.distance,
  });

  @override
  State<PhaseAView> createState() => _PhaseAViewState();
}

class _PhaseAViewState extends State<PhaseAView> {
  // Local state for phase steps
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    final distanceText = widget.distance != null
        ? (widget.distance! / 1000).toStringAsFixed(2)
        : 'Unknown';
    final errorMsg =
        'You must be within 50m of the location. Current distance: $distanceText km';

    if (widget.order.computedStatus == OrderStatus.scheduled) {
      if (_currentStep == 0) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.locationWidget,
            if (widget.order.heavyItems != null &&
                widget.order.heavyItems!.isNotEmpty &&
                widget.order.heavyItems != 'None' &&
                widget.order.heavyItems != 'No')
              OrderAlertBanner(
                title: 'Heavy Items',
                message: 'This order contains: ${widget.order.heavyItems}',
                color: Colors.orange.shade800,
                icon: Icons.warning_amber_rounded,
              ),
            OrderInfoCard(
              title: 'Customer Name',
              content: widget.order.userName.isNotEmpty
                  ? widget.order.userName
                  : 'N/A',
              icon: Icons.person,
            ),
            const SizedBox(height: 12),
            if (widget.order.userPhone.isNotEmpty)
              OrderInfoCard(
                title: 'Customer Phone',
                content: widget.order.userPhone,
                icon: Icons.phone,
                onActionTap: () =>
                    LauncherUtils.launchPhone(context, widget.order.userPhone),
                actionIcon: Icons.call,
              ),
            const SizedBox(height: 12),
            const Divider(height: 32),
            OrderNavigationStep(
              title: 'Pickup from User',
              address: widget.order.userAddress,
              buttonText: 'Arrived at Location',
              onButtonPressed: widget.isEnabled
                  ? () async {
                      context.read<OrderBloc>().add(
                        NotifyUserEvent(orderId: widget.order.orderId ?? ''),
                      );
                      setState(() => _currentStep = 1);
                    }
                  : () {
                      AppAlerts.showErrorSnackBar(
                        context: context,
                        message: errorMsg,
                      );
                    },
              onActionTap: () =>
                  LauncherUtils.launchMaps(context, widget.order.userAddress),
            ),
            const SizedBox(height: 16),
          ],
        );
      } else if (_currentStep == 1) {
        return OrderPickupForm(
          onSubmitted: () {
            // Bypass QR Scan step
            // setState(() => _currentStep = 2);
            context.read<OrderBloc>().add(ScanQrCode());
          },
        );
      }
      // else if (_currentStep == 2) {
      //   return OrderScanQrStep(
      //     onScanCompleted: () {
      //       context.read<OrderBloc>().add(ScanQrCode());
      //     },
      //   );
      // }
    } else if (widget.order.computedStatus == OrderStatus.pickedUp) {
      return Column(
        children: [
          widget.locationWidget,
          if (widget.order.hubId?.name != null) ...[
            OrderInfoCard(
              title: 'Hub Name',
              content: widget.order.hubId!.name!,
              icon: Icons.store,
            ),
            const SizedBox(height: 12),
          ],
          if (widget.order.hubId?.primaryContact != null) ...[
            OrderInfoCard(
              title: 'Hub Contact',
              content: widget.order.hubId!.primaryContact!,
              icon: Icons.phone,
              onActionTap: () => LauncherUtils.launchPhone(
                context,
                widget.order.hubId!.primaryContact!,
              ),
              actionIcon: Icons.call,
            ),
            const SizedBox(height: 12),
          ],
          OrderNavigationStep(
            title: 'Deliver to Hub',
            address: widget.order.hubAddress,
            buttonText: 'Confirm Drop',
            onButtonPressed: widget.isEnabled
                ? () async {
                    context.read<OrderBloc>().add(ConfirmHubDrop());
                  }
                : () {
                    AppAlerts.showErrorSnackBar(
                      context: context,
                      message: errorMsg,
                    );
                  },
            onActionTap: () =>
                LauncherUtils.launchMaps(context, widget.order.hubAddress),
          ),
        ],
      );
    } else if (widget.order.computedStatus == OrderStatus.processing) {
      return OrderCompletedView(order: widget.order);
    }
    return const SizedBox.shrink();
  }
}

class PhaseBView extends StatelessWidget {
  final OrderDetailsEntity order;
  final bool isEnabled;
  final Widget locationWidget;
  final double? distance;

  const PhaseBView({
    super.key,
    required this.order,
    required this.isEnabled,
    required this.locationWidget,
    this.distance,
  });

  @override
  Widget build(BuildContext context) {
    final distanceText = distance != null
        ? (distance! / 1000).toStringAsFixed(2)
        : 'Unknown';
    final errorMsg =
        'You must be within 50m of the location. Current: $distanceText km';

    if (order.computedStatus == OrderStatus.readyToPickupFromHub) {
      return Column(
        children: [
          locationWidget,
          if (order.hubId?.name != null) ...[
            OrderInfoCard(
              title: 'Hub Name',
              content: order.hubId!.name!,
              icon: Icons.store,
            ),
            const SizedBox(height: 12),
          ],
          OrderNavigationStep(
            title: 'Pickup from Hub',
            address: order.hubAddress,
            buttonText: 'Confirm Pickup',
            onButtonPressed: isEnabled
                ? () async {
                    context.read<OrderBloc>().add(ConfirmVendorPickup());
                  }
                : () {
                    AppAlerts.showErrorSnackBar(
                      context: context,
                      message: errorMsg,
                    );
                  },
            onActionTap: () =>
                LauncherUtils.launchMaps(context, order.hubAddress),
          ),
        ],
      );
    } else if (order.computedStatus == OrderStatus.vendorPickedUp) {
      return Column(
        children: [
          locationWidget,
          if (order.vendorId?.companyName != null) ...[
            OrderInfoCard(
              title: 'Vendor Name',
              content: order.vendorId!.companyName!,
              icon: Icons.store,
            ),
            const SizedBox(height: 12),
          ],
          if (order.vendorId?.phoneNumber != null) ...[
            OrderInfoCard(
              title: 'Vendor Phone',
              content: order.vendorId!.phoneNumber!,
              icon: Icons.phone,
              onActionTap: () => LauncherUtils.launchPhone(
                context,
                order.vendorId!.phoneNumber!,
              ),
              actionIcon: Icons.call,
            ),
            const SizedBox(height: 12),
          ],
          OrderNavigationStep(
            title: 'Deliver to Vendor',
            address: order.vendorAddress,
            buttonText: 'Confirm Drop',
            onButtonPressed: isEnabled
                ? () async {
                    context.read<OrderBloc>().add(ConfirmVendorDrop());
                  }
                : () {
                    AppAlerts.showErrorSnackBar(
                      context: context,
                      message: errorMsg,
                    );
                  },
            onActionTap: () =>
                LauncherUtils.launchMaps(context, order.vendorAddress),
          ),
        ],
      );
    } else if (order.computedStatus == OrderStatus.washing) {
      return OrderCompletedView(order: order);
    }

    return const SizedBox.shrink();
  }
}

class PhaseCView extends StatelessWidget {
  final OrderDetailsEntity order;
  final bool isEnabled;
  final Widget locationWidget;
  final double? distance;

  const PhaseCView({
    super.key,
    required this.order,
    required this.isEnabled,
    required this.locationWidget,
    this.distance,
  });

  @override
  Widget build(BuildContext context) {
    final distanceText = distance != null
        ? (distance! / 1000).toStringAsFixed(2)
        : 'Unknown';
    final errorMsg =
        'You must be within 50m of the location. Current: $distanceText km';

    if (order.computedStatus == OrderStatus.serviceCompleted) {
      return Column(
        children: [
          locationWidget,
          if (order.vendorId?.companyName != null) ...[
            OrderInfoCard(
              title: 'Vendor Name',
              content: order.vendorId!.companyName!,
              icon: Icons.store,
            ),
            const SizedBox(height: 12),
          ],
          if (order.vendorId?.phoneNumber != null) ...[
            OrderInfoCard(
              title: 'Vendor Phone',
              content: order.vendorId!.phoneNumber!,
              icon: Icons.phone,
              onActionTap: () => LauncherUtils.launchPhone(
                context,
                order.vendorId!.phoneNumber!,
              ),
              actionIcon: Icons.call,
            ),
            const SizedBox(height: 12),
          ],
          OrderNavigationStep(
            title: 'Pickup from Vendor',
            address: order.vendorAddress,
            buttonText: 'Confirm Pickup',
            onButtonPressed: isEnabled
                ? () async {
                    context.read<OrderBloc>().add(ConfirmHubReturnPickup());
                  }
                : () {
                    AppAlerts.showErrorSnackBar(
                      context: context,
                      message: errorMsg,
                    );
                  },
            onActionTap: () =>
                LauncherUtils.launchMaps(context, order.vendorAddress),
          ),
        ],
      );
    } else if (order.computedStatus == OrderStatus.vendorReturning) {
      return Column(
        children: [
          locationWidget,
          if (order.hubId?.name != null) ...[
            OrderInfoCard(
              title: 'Hub Name',
              content: order.hubId!.name!,
              icon: Icons.store,
            ),
            const SizedBox(height: 12),
          ],
          OrderNavigationStep(
            title: 'Return to Hub',
            address: order.hubAddress,
            buttonText: 'Confirm Drop',
            onButtonPressed: isEnabled
                ? () async {
                    context.read<OrderBloc>().add(ConfirmHubReturnDrop());
                  }
                : () {
                    AppAlerts.showErrorSnackBar(
                      context: context,
                      message: errorMsg,
                    );
                  },
            onActionTap: () =>
                LauncherUtils.launchMaps(context, order.hubAddress),
          ),
        ],
      );
    } else if (order.computedStatus == OrderStatus.processing) {
      return OrderCompletedView(order: order);
    }
    return const SizedBox.shrink();
  }
}

class PhaseDView extends StatefulWidget {
  final OrderDetailsEntity order;
  final bool isEnabled;
  final Widget locationWidget;
  final double? distance;
  final Widget? deliveryForm; // Pass Pre-built form if easier, or build inside

  const PhaseDView({
    super.key,
    required this.order,
    required this.isEnabled,
    required this.locationWidget,
    this.distance,
    this.deliveryForm,
  });

  @override
  State<PhaseDView> createState() => _PhaseDViewState();
}

class _PhaseDViewState extends State<PhaseDView> {
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    final distanceText = widget.distance != null
        ? (widget.distance! / 1000).toStringAsFixed(2)
        : 'Unknown';
    final errorMsg =
        'You must be within 50m of the location. Current: $distanceText km';

    if (widget.order.computedStatus == OrderStatus.readyToPickupFromHub) {
      return Column(
        children: [
          widget.locationWidget,
          if (widget.order.hubId?.name != null) ...[
            OrderInfoCard(
              title: 'Hub Name',
              content: widget.order.hubId!.name!,
              icon: Icons.store,
            ),
            const SizedBox(height: 12),
          ],
          OrderNavigationStep(
            title: 'Pickup from Hub',
            address: widget.order.hubAddress,
            buttonText: 'Confirm Pickup',
            onButtonPressed: widget.isEnabled
                ? () async {
                    context.read<OrderBloc>().add(StartDelivery());
                  }
                : () {
                    AppAlerts.showErrorSnackBar(
                      context: context,
                      message: errorMsg,
                    );
                  },
            onActionTap: () =>
                LauncherUtils.launchMaps(context, widget.order.hubAddress),
          ),
        ],
      );
    } else if (widget.order.computedStatus == OrderStatus.outForDelivery) {
      // If delivery form is already shown?
      // Actually logic was: if _currentStep == 0 -> Show Arrived Button.
      // If _currentStep == 1 -> Show Delivery Form.

      if (_currentStep == 0) {
        return Column(
          children: [
            widget.locationWidget,
            if (widget.order.computedStatus == OrderStatus.outForDelivery &&
                widget.order.paymentStatus?.toLowerCase() != 'paid')
              OrderAlertBanner(
                title: 'Collect Cash',
                message:
                    'Collect ₹${widget.order.estimateTotalPrice ?? widget.order.totalPrice ?? 0} from the customer.',
                color: Colors.red.shade700,
                icon: Icons.payments_outlined,
              ),
            OrderInfoCard(
              title: 'Customer Name',
              content: widget.order.userName.isNotEmpty
                  ? widget.order.userName
                  : 'N/A',
              icon: Icons.person,
            ),
            const SizedBox(height: 12),
            if (widget.order.userPhone.isNotEmpty)
              OrderInfoCard(
                title: 'Customer Phone',
                content: widget.order.userPhone,
                icon: Icons.phone,
                onActionTap: () =>
                    LauncherUtils.launchPhone(context, widget.order.userPhone),
                actionIcon: Icons.call,
              ),
            const SizedBox(height: 12),
            const Divider(height: 32),
            OrderNavigationStep(
              title: 'Deliver to User',
              address: widget.order.userAddress,
              buttonText: 'Arrived at Location',
              onButtonPressed: widget.isEnabled
                  ? () async {
                      context.read<OrderBloc>().add(
                        NotifyUserEvent(orderId: widget.order.orderId ?? ''),
                      );
                      setState(() => _currentStep = 1);
                    }
                  : () {
                      AppAlerts.showErrorSnackBar(
                        context: context,
                        message: errorMsg,
                      );
                    },
              onActionTap: () =>
                  LauncherUtils.launchMaps(context, widget.order.userAddress),
            ),
          ],
        );
      } else {
        // Return passed delivery form or similar
        return widget.deliveryForm ?? const SizedBox.shrink();
      }
    } else if (widget.order.computedStatus == OrderStatus.delivered) {
      return OrderCompletedView(order: widget.order);
    }
    return const SizedBox.shrink();
  }
}
