import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/constants/status_extensions.dart';
import '../../../../core/injection_container.dart';
import '../../../../core/services/shared_preferences_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../order/domain/entities/accept_order_params.dart';
import '../../domain/entities/get_orders_entity.dart';
import '../../../order/presentation/bloc/order_bloc.dart';
import '../../../order/presentation/bloc/order_event.dart';
import '../../../order/presentation/bloc/order_state.dart';
import '../bloc/home_bloc.dart';
import '../home_router.dart';

class OrderListItem extends StatefulWidget {
  final OrderDetailsEntity order;
  final VoidCallback onTap;
  final VoidCallback? onSkip;

  const OrderListItem({
    super.key,
    required this.order,
    required this.onTap,
    this.onSkip,
  });

  @override
  State<OrderListItem> createState() => _OrderListItemState();
}

class _OrderListItemState extends State<OrderListItem> {
  late OrderBloc _orderBloc;
  final String? deliveryAgentId = SharedPreferencesService.getString(
    AppConstants.kAgentId,
  );

  @override
  void initState() {
    super.initState();
    _orderBloc = sl<OrderBloc>();
    _orderBloc.add(OrderLoadEvent(order: widget.order));

    final target = _getTargetAddress(widget.order);
    if (target.isNotEmpty) {
      _orderBloc.add(InitLocationEvent(targetAddress: target));
    }
  }

  @override
  void dispose() {
    _orderBloc.close();
    super.dispose();
  }

  String _getTargetAddress(OrderDetailsEntity order) {
    switch (order.computedStatus) {
      // Phase A: User -> Hub
      case OrderStatus.scheduled:
        return order.userAddress; // Pickup from User
      case OrderStatus.pickedUp:
        return order.hubAddress; // Deliver to Hub

      // Phase B: Hub -> Vendor (Removed)
      // case OrderStatus.readyToPickupFromHub:
      //   return order.hubAddress; // Pickup from Hub
      // case OrderStatus.vendorPickedUp:
      //   return order.vendorAddress; // Deliver to Vendor

      // Phase C: Vendor -> Hub (Removed)
      // case OrderStatus.serviceCompleted:
      //   return order.vendorAddress; // Pickup from Vendor
      // case OrderStatus.vendorReturning:
      //   return order.hubAddress; // Deliver to Hub

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
    return BlocProvider.value(
      value: _orderBloc,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
            border: Border.all(color: AppColors.lightBorderColor, width: 1),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withValues(alpha: 0.1),
                              AppColors.primary.withValues(alpha: 0.2),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.receipt_long_rounded,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order #${widget.order.orderId}',
                              style: AppTextStyles.textMediumfs16(context)
                                  .copyWith(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 17,
                                    height: 1.2,
                                    color: AppColors.headerTextColor,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.lightSurface,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _formatDate(widget.order.createdAt),
                                style: AppTextStyles.smallTextStyle(context)
                                    .copyWith(
                                      color: AppColors.greyTextColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildStatusBadge(context, widget.order.status),
                    ],
                  ),

                  if (widget.order.computedStatus.agentStatus !=
                      DeliveryAgentStatus.delivered) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.lightBorderColor,
                              AppColors.lightBorderColor.withValues(alpha: 0.5),
                              AppColors.lightBorderColor,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.location_on_rounded,
                                      size: 14,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Pickup Location',
                                    style: AppTextStyles.smallTextStyle(context)
                                        .copyWith(
                                          color: AppColors.greyTextColor,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.5,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _getTargetAddress(widget.order),
                                style: AppTextStyles.mediumTextStyle(context)
                                    .copyWith(
                                      fontWeight: FontWeight.w700,
                                      height: 1.4,
                                      color: AppColors.textColor,
                                      fontSize: 15,
                                    ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 12),
                              BlocBuilder<OrderBloc, OrderState>(
                                builder: (context, state) {
                                  if (state is OrderLoaded) {
                                    if (state.isLocationLoading) {
                                      return const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                AppColors.primary,
                                              ),
                                        ),
                                      );
                                    }
                                    if (state.distanceInMeters != null) {
                                      final km =
                                          (state.distanceInMeters! / 1000)
                                              .toStringAsFixed(1);
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.accent,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: AppColors.primary.withValues(
                                              alpha: 0.2,
                                            ),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.near_me_rounded,
                                              size: 14,
                                              color: AppColors.primary,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              '$km km away',
                                              style:
                                                  AppTextStyles.smallTextStyle(
                                                    context,
                                                  ).copyWith(
                                                    fontWeight: FontWeight.w700,
                                                    color: AppColors.primary,
                                                    fontSize: 13,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        if (widget.order.computedStatus.name ==
                            OrderStatus.scheduled.name)
                          Expanded(
                            child: Row(
                              children: [
                                if (widget.onSkip != null) ...[
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: widget.onSkip,
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        side: BorderSide(
                                          color: AppColors.redColor.withValues(
                                            alpha: 0.5,
                                          ),
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        'Skip',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.redColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                ],
                                Expanded(
                                  flex: 2,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      context.read<HomeBloc>().add(
                                        AcceptOrderEvent(
                                          params: AcceptOrderParams(
                                            orderId: widget.order.orderId ?? '',
                                            type:
                                                widget
                                                        .order
                                                        .computedStatus
                                                        .name ==
                                                    OrderStatus.scheduled.name
                                                ? 'pickup'
                                                : 'return',
                                          ),
                                        ),
                                      );
                                      if (context.read<HomeBloc>().state
                                          is! HomeError) {
                                        await Navigator.pushReplacementNamed(
                                          context,
                                          HomeRouter.orderDetail,
                                          arguments: widget.order,
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      elevation: 3,
                                      shadowColor: AppColors.primary.withValues(
                                        alpha: 0.4,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text(
                                      'Accept',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, String? status) {
    // Convert string status to OrderStatus to use our extension
    final orderStatus = widget
        .order
        .computedStatus; // Helper getter in entity handles string conversion
    final agentStatus = orderStatus.agentStatus;

    Color backgroundColor;
    Color textColor;

    switch (agentStatus) {
      case DeliveryAgentStatus.delivered:
        backgroundColor = Colors.green.withValues(alpha: 0.1);
        textColor = Colors.green;
        break;
      case DeliveryAgentStatus.cancelled:
        backgroundColor = Colors.red.withValues(alpha: 0.1);
        textColor = Colors.red;
        break;
      case DeliveryAgentStatus.pickup:
      case DeliveryAgentStatus.transit:
      case DeliveryAgentStatus.accepted:
        backgroundColor = AppColors.primary.withValues(alpha: 0.1);
        textColor = AppColors.primary;
        break;
      case DeliveryAgentStatus.unknown:
        backgroundColor = Colors.grey.withValues(alpha: 0.1);
        textColor = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        agentStatus.label,
        style: AppTextStyles.smallTextStyle(
          context,
        ).copyWith(color: textColor, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('MMM d, y • h:mm a').format(date);
  }
}
