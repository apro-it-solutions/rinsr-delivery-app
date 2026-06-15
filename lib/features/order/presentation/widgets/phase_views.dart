import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/enums.dart';
import '../../../../core/services/shared_preferences_service.dart';
import '../../../../core/utils/app_alerts.dart';
import '../../../../core/utils/launcher_utils.dart';
import '../../../home/domain/entities/get_orders_entity.dart';
import '../bloc/order_bloc.dart';
import '../widgets/order_completed_view.dart';
import '../widgets/order_info_card.dart';
import '../widgets/order_navigation_step.dart';
import '../widgets/order_pickup_form.dart';
import '../widgets/order_alert_banner.dart';
import '../pages/barcode_scanner_screen.dart';

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
  // 0: Arrived at Location
  // 1: Pickup Details (Photo, Weight, Scan)
  int _currentStep = 0;

  // Once the agent swipes "Arrived at Location" they shouldn't be able to fall
  // back to the navigation step. The backend status stays `scheduled` until
  // pickup is submitted, so we persist the arrived flag locally to survive a
  // refresh, app restart, or re-entering the order.
  String get _arrivedKey => 'arrived_pickup_${widget.order.orderId ?? ''}';

  @override
  void initState() {
    super.initState();
    if (widget.order.orderId != null &&
        (SharedPreferencesService.getBool(_arrivedKey) ?? false)) {
      _currentStep = 1;
    }
  }

  // Issue 10: once the agent has called the customer this many times without an
  // answer, reveal a "Cancel Order" option for unreachable customers.
  static const int _cancelCallThreshold = 5;
  int _customerCallAttempts = 0;

  void _callCustomer() {
    LauncherUtils.launchPhone(context, widget.order.userPhone);
    setState(() => _customerCallAttempts++);
  }

  Future<void> _confirmCancelOrder() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Order?'),
        content: const Text(
          'The customer has not answered after multiple calls. '
          'Cancelling will end this pickup and return you to home.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep Trying'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cancel Order'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      if (widget.order.orderId != null) {
        await SharedPreferencesService.remove(_arrivedKey);
      }
      if (!mounted) return;
      context.read<OrderBloc>().add(
        const CancelOrderEvent(
          reason: 'Customer not answering calls during pickup',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.order.computedStatus == OrderStatus.scheduled) {
      // Step 0: Arrived at Location
      if (_currentStep == 0) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              widget.locationWidget,
              if (widget.order.heavyItems != null &&
                  widget.order.heavyItems!.isNotEmpty &&
                  widget.order.heavyItems != 'None' &&
                  widget.order.heavyItems != 'No') ...[
                const SizedBox(height: 16),
                OrderAlertBanner(
                  title: 'Heavy Items',
                  message: 'This order contains: ${widget.order.heavyItems}',
                  color: Colors.orange.shade800,
                  icon: Icons.warning_amber_rounded,
                ),
              ],
              const SizedBox(height: 16),
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
                  onActionTap: _callCustomer,
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
                        if (widget.order.orderId != null) {
                          await SharedPreferencesService.setBool(
                            _arrivedKey,
                            true,
                          );
                        }
                        if (!mounted) return;
                        setState(() {
                          _currentStep = 1;
                        });
                      }
                    : () {
                        final distanceText = widget.distance != null
                            ? (widget.distance! / 1000).toStringAsFixed(2)
                            : 'Unknown';
                        final errorMsg =
                            'You must be within 50m of the location. Current distance: $distanceText km';
                        AppAlerts.showErrorSnackBar(
                          context: context,
                          message: errorMsg,
                        );
                      },
                onActionTap: () =>
                    LauncherUtils.launchMaps(context, widget.order.userAddress, coordinates: widget.order.pickupAddress?.coordinates),
              ),
              if (_customerCallAttempts >= _cancelCallThreshold) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _confirmCancelOrder,
                    icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                    label: const Text(
                      'Cancel Order (Customer Unreachable)',
                      style: TextStyle(color: Colors.red),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        );
      } else if (_currentStep == 1) {
        return OrderPickupForm(
          order: widget.order,
          onSubmitted: (photoPath, weight, barcode) {
            context.read<OrderBloc>().add(
              SubmitPickupDetails(
                barcode: barcode,
                photoPath: photoPath,
                weight: weight,
              ),
            );
          },
        );
      }
    } else if (widget.order.computedStatus == OrderStatus.pickedUp) {
      return Column(
        children: [
          widget.locationWidget,
          if (widget.order.vendorId?.companyName != null) ...[
            OrderInfoCard(
              title: 'Vendor Name',
              content: widget.order.vendorId!.companyName!,
              icon: Icons.store,
            ),
            const SizedBox(height: 12),
          ],
          if (widget.order.vendorId?.phoneNumber != null) ...[
            OrderInfoCard(
              title: 'Vendor Contact',
              content: widget.order.vendorId!.phoneNumber!,
              icon: Icons.phone,
              onActionTap: () => LauncherUtils.launchPhone(
                context,
                widget.order.vendorId!.phoneNumber!,
              ),
              actionIcon: Icons.call,
            ),
            const SizedBox(height: 12),
          ],
          OrderNavigationStep(
            title: 'Deliver to Vendor',
            address: widget.order.vendorAddress,
            buttonText: 'Confirm Drop',
            onButtonPressed: widget.isEnabled
                ? () async {
                    context.read<OrderBloc>().add(ConfirmHubDrop());
                  }
                : () {
                    final distanceText = widget.distance != null
                        ? (widget.distance! / 1000).toStringAsFixed(2)
                        : 'Unknown';
                    final errorMsg =
                        'You must be within 50m of the location. Current distance: $distanceText km';
                    AppAlerts.showErrorSnackBar(
                      context: context,
                      message: errorMsg,
                    );
                  },
            onActionTap: () =>
                LauncherUtils.launchMaps(context, widget.order.vendorAddress, coordinates: widget.order.vendorId?.locationCoordinates),
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
          if (order.vendorId?.companyName != null) ...[
            OrderInfoCard(
              title: 'Vendor Name',
              content: order.vendorId!.companyName!,
              icon: Icons.store,
            ),
            const SizedBox(height: 12),
          ],
          OrderNavigationStep(
            title: 'Pickup from vendor',
            address: order.vendorAddress,
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
                LauncherUtils.launchMaps(context, order.vendorAddress, coordinates: order.vendorId?.locationCoordinates),
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
                LauncherUtils.launchMaps(context, order.vendorAddress, coordinates: order.vendorId?.locationCoordinates),
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
                LauncherUtils.launchMaps(context, order.vendorAddress, coordinates: order.vendorId?.locationCoordinates),
          ),
        ],
      );
    } else if (order.computedStatus == OrderStatus.vendorReturning) {
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
          OrderNavigationStep(
            title: 'Return to vendor',
            address: order.vendorAddress,
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
                LauncherUtils.launchMaps(context, order.vendorAddress, coordinates: order.vendorId?.locationCoordinates),
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

  // Mirror of PhaseA: lock the agent onto the delivery form once "Arrived at
  // Location" is swiped, even across restarts (status stays `out_for_delivery`
  // until proof of delivery is submitted).
  String get _arrivedKey => 'arrived_delivery_${widget.order.orderId ?? ''}';

  @override
  void initState() {
    super.initState();
    if (widget.order.orderId != null &&
        (SharedPreferencesService.getBool(_arrivedKey) ?? false)) {
      _currentStep = 1;
    }
  }

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
          if (widget.order.vendorId?.companyName != null) ...[
            OrderInfoCard(
              title: 'Vendor Name',
              content: widget.order.vendorId!.companyName!,
              icon: Icons.store,
            ),
            const SizedBox(height: 12),
          ],
          if (widget.order.vendorId?.phoneNumber != null) ...[
            OrderInfoCard(
              title: 'Vendor Phone',
              content: widget.order.vendorId!.phoneNumber!,
              icon: Icons.phone,
              onActionTap: () => LauncherUtils.launchPhone(
                context,
                widget.order.vendorId!.phoneNumber!,
              ),
              actionIcon: Icons.call,
            ),
            const SizedBox(height: 12),
          ],
          OrderNavigationStep(
            title: 'Pickup from Vendor',
            address: widget.order.vendorAddress,
            buttonText: 'Confirm Pickup',
            onButtonPressed: widget.isEnabled
                ? () async {
                    // 1. Scan Barcode
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BarcodeScannerScreen(),
                      ),
                    );

                    // 2. Validate Barcode
                    if (result != null && context.mounted) {
                      if (result == widget.order.barcode) {
                        context.read<OrderBloc>().add(StartDelivery());
                      } else {
                        AppAlerts.showErrorSnackBar(
                          context: context,
                          message: 'Scanned barcode does not match order!',
                        );
                      }
                    }
                  }
                : () {
                    AppAlerts.showErrorSnackBar(
                      context: context,
                      message: errorMsg,
                    );
                  },
            onActionTap: () =>
                LauncherUtils.launchMaps(context, widget.order.vendorAddress, coordinates: widget.order.vendorId?.locationCoordinates),
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
                      if (widget.order.orderId != null) {
                        await SharedPreferencesService.setBool(
                          _arrivedKey,
                          true,
                        );
                      }
                      if (!mounted) return;
                      setState(() => _currentStep = 1);
                    }
                  : () {
                      AppAlerts.showErrorSnackBar(
                        context: context,
                        message: errorMsg,
                      );
                    },
              onActionTap: () =>
                  LauncherUtils.launchMaps(context, widget.order.userAddress, coordinates: widget.order.pickupAddress?.coordinates),
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
