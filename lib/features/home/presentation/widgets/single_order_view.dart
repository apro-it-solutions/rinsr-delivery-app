import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/constants/status_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/injection_container.dart';
import '../../domain/entities/get_orders_entity.dart';
import '../../../order/domain/entities/accept_order_params.dart';
import '../../../order/presentation/bloc/order_bloc.dart';
import '../bloc/home_bloc.dart';
import '../home_router.dart';

class SingleOrderView extends StatefulWidget {
  final OrderDetailsEntity order;
  final VoidCallback? onSkip;
  final Future<void> Function()? onRefresh;

  const SingleOrderView({
    super.key,
    required this.order,
    this.onSkip,
    this.onRefresh,
  });

  @override
  State<SingleOrderView> createState() => _SingleOrderViewState();
}

class _SingleOrderViewState extends State<SingleOrderView> {
  late OrderBloc _orderBloc;

  @override
  void initState() {
    super.initState();
    _orderBloc = sl<OrderBloc>();
    _orderBloc.add(OrderLoadEvent(order: widget.order));
    // Trigger location calculation if needed, similar to OrderListItem
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
      case OrderStatus.scheduled:
        return order.userAddress;
      case OrderStatus.pickedUp:
        return order.hubAddress;
      case OrderStatus.ready:
        return order.hubAddress;
      case OrderStatus.outForDelivery:
        return order.userAddress;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _orderBloc,
      child: Container(
        color: AppColors.lightBackground,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: widget.onRefresh ?? () async {},
                  notificationPredicate: widget.onRefresh != null
                      ? defaultScrollNotificationPredicate
                      : (_) => false,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildHeaderCard(context),
                        const SizedBox(height: 16),
                        _buildLocationCard(context),
                        const SizedBox(height: 16),
                        _buildOrderDetailsCard(context),
                      ],
                    ),
                  ),
                ),
              ),
              _buildBottomAction(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightBorderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #RIN-${widget.order.displayOrderID}',
                      style: AppTextStyles.textMediumfs18(context).copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.headerTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildStatusBadge(context),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: AppColors.dividerColor),
          ),
          _buildDistanceInfo(context),
        ],
      ),
    );
  }

  Widget _buildDistanceInfo(BuildContext context) {
    return BlocBuilder<OrderBloc, OrderState>(
      builder: (context, state) {
        String distance = '-- km';
        String duration = '-- min';

        if (state is OrderLoaded && state.distanceInMeters != null) {
          distance =
              '${(state.distanceInMeters! / 1000).toStringAsFixed(1)} km';
          final minutes = (state.distanceInMeters! / 1000 * 3).round();
          duration = '$minutes mins';
        }

        return Row(
          children: [
            _buildInfoChip(
              context,
              Icons.access_time_filled,
              duration,
              AppColors.primary,
            ),
            const SizedBox(width: 12),
            _buildInfoChip(
              context,
              Icons.directions_bike,
              distance,
              AppColors.primaryGreyColor,
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoChip(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTextStyles.mediumTextStyle(
              context,
            ).copyWith(fontWeight: FontWeight.w600, fontSize: 13, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    final status = widget.order.computedStatus.agentStatus;
    Color bg = AppColors.primary.withValues(alpha: 0.1);
    Color text = AppColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: AppTextStyles.smallTextStyle(
          context,
        ).copyWith(color: text, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildLocationCard(BuildContext context) {
    // Defines the flow direction:
    // true: User -> Hub (Scheduled or Picked Up/Transit to Hub)
    // false: Hub -> User (Ready or Out For Delivery/Transit to User)
    final isPickupFlow =
        widget.order.computedStatus == OrderStatus.scheduled ||
        widget.order.computedStatus == OrderStatus.pickedUp ||
        widget.order.computedStatus == OrderStatus.outForDelivery;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightBorderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TRIP ROUTE',
            style: AppTextStyles.smallTextStyle(context).copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.lightGreyText,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 20),
          _buildLocationItem(
            context,
            title: 'PICKUP',
            address: isPickupFlow
                ? (widget.order.userAddress)
                : (widget.order.hubAddress),
            name: isPickupFlow
                ? (widget.order.userName.isNotEmpty
                      ? widget.order.userName
                      : 'Customer')
                : (widget.order.hubId?.name ?? 'Hub'),
            isPickup: true,
            isLast: false,
          ),
          _buildLocationItem(
            context,
            title: 'DROP',
            address: isPickupFlow
                ? (widget.order.hubAddress)
                : (widget.order.userAddress),
            name: isPickupFlow
                ? (widget.order.hubId?.name ?? 'Hub')
                : (widget.order.userName),
            isPickup: false,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationItem(
    BuildContext context, {
    required String title,
    required String name,
    required String address,
    required bool isPickup,
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isPickup ? AppColors.accent : AppColors.lightSurface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isPickup
                        ? AppColors.primary
                        : AppColors.primaryGreyColor,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isPickup
                          ? AppColors.primary
                          : AppColors.primaryGreyColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: AppColors.lineColor,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.smallTextStyle(context).copyWith(
                      color: AppColors.primaryGreyColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    name.isNotEmpty ? name : 'Unknown',
                    style: AppTextStyles.textMediumfs16(context).copyWith(
                      color: AppColors.headerTextColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address,
                    style: AppTextStyles.mediumTextStyle(
                      context,
                    ).copyWith(color: AppColors.greyTextColor, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetailsCard(BuildContext context) {
    final itemValue = widget.order.totalNoOfClothes ?? '0';
    final weightValue = widget.order.totalWeightKg ?? '0';
    // Use heavy items or other field if needed
    final hasHeavy =
        widget.order.heavyItems != null && widget.order.heavyItems == 'yes';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightBorderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ORDER DETAILS',
            style: AppTextStyles.smallTextStyle(context).copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.lightGreyText,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  context,
                  Icons.local_laundry_service_outlined,
                  'Clothes',
                  '$itemValue Items',
                ),
              ),
              Container(width: 1, height: 40, color: AppColors.dividerColor),
              Expanded(
                child: _buildDetailItem(
                  context,
                  Icons.scale_outlined,
                  'Weight',
                  '$weightValue Kg',
                ),
              ),
            ],
          ),
          if (hasHeavy) ...[
            const SizedBox(height: 16),
            const Divider(color: AppColors.dividerColor),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Contains Heavy Items',
                  style: AppTextStyles.mediumTextStyle(context).copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 28),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTextStyles.smallTextStyle(
            context,
          ).copyWith(color: AppColors.greyTextColor),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.textMediumfs16(context).copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.headerTextColor,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomAction(BuildContext context) {
    // Check if the order is already in progress (Transit)
    // We treat 'transit' as the state where the agent has picked it up.
    // Confirm status logic from status_extensions.dart if needed, but usually agentStatus calls it transit.
    final isTransit =
        widget.order.computedStatus.agentStatus ==
        DeliveryAgentStatus.delivered;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -4),
            blurRadius: 16,
          ),
        ],
      ),
      child: SafeArea(
        child: isTransit
            ? SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    // Navigate to details without accepting again
                    await Navigator.pushNamed(
                      context,
                      HomeRouter.orderDetail,
                      arguments: widget.order,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'VIEW DETAILS',
                    style: AppTextStyles.mediumTextStyle(context).copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              )
            : Row(
                children: [
                  if (widget.onSkip != null) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: widget.onSkip,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: AppColors.redColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'SKIP',
                          style: AppTextStyles.mediumTextStyle(context)
                              .copyWith(
                                color: AppColors.redColor,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
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
                                  widget.order.computedStatus ==
                                      OrderStatus.scheduled
                                  ? 'pickup'
                                  : 'return',
                            ),
                          ),
                        );
                        // if (context.read<HomeBloc>().state is! HomeError) {
                        //   await Navigator.pushReplacementNamed(
                        //     context,
                        //     HomeRouter.orderDetail,
                        //     arguments: widget.order,
                        //   );
                        // }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'ACCEPT ORDER',
                        style: AppTextStyles.mediumTextStyle(context).copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
