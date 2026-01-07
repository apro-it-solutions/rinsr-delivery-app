import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/enums.dart';

import '../../domain/entities/get_orders_entity.dart';
import '../bloc/home_bloc.dart';
import '../home_router.dart';
import 'order_list_item.dart';

class AnimatedOrderStack extends StatefulWidget {
  final List<OrderDetailsEntity> orders;
  final Function(OrderDetailsEntity) onSkip;
  final String? deliveryAgentId;

  const AnimatedOrderStack({
    super.key,
    required this.orders,
    required this.onSkip,
    this.deliveryAgentId,
  });

  @override
  State<AnimatedOrderStack> createState() => _AnimatedOrderStackState();
}

class _AnimatedOrderStackState extends State<AnimatedOrderStack>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(1.5, 0), // Slide off to the right
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSkip(OrderDetailsEntity order) async {
    // 1. Play animation
    await _controller.forward();

    // 2. Call parent callback to update list
    widget.onSkip(order);

    // 3. Reset animation for the next card (which is now top)
    // We add a small delay or just reset immediately if the list is rebuilt
    // But since the parent rebuilds effectively replacing this widget or updating props,
    // we should prepare the controller to be at zero.
    _controller.reset();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.orders.isEmpty) return const SizedBox.shrink();

    // Limit to showing top 3 cards for performance and visual clarity
    // Order: Bottom (Back) -> Top (Front)
    // We want to render index 2, then 1, then 0 (top)

    final visibleCount = widget.orders.length;
    final List<Widget> stackChildren = [];

    for (int i = visibleCount - 1; i >= 0; i--) {
      final isTop = i == 0;
      final order = widget.orders[i];

      // Calculate styles based on index (0 is top)
      const double scale = 1; // 1.0, 0.95, 0.90
      final double transY = i * 50.0; // Increased spacing to show headers

      Widget card = _buildCardStructure(
        context,
        order,
        isTop: isTop,
        scale: scale,
        transY: transY,
      );

      // Wrap top card in animation slide
      if (isTop) {
        card = SlideTransition(position: _slideAnimation, child: card);
      }

      stackChildren.add(card);
    }

    return Stack(alignment: Alignment.topCenter, children: stackChildren);
  }

  Widget _buildCardStructure(
    BuildContext context,
    OrderDetailsEntity order, {
    required bool isTop,
    required double scale,
    required double transY,
  }) {
    // If it's a background card, we just show a container with decoration
    // If it's the top card, we show the full OrderListItem

    // If it's a background card, we render the OrderListItem but disabled/faded
    // This allows "details" to peek through (like colors, layout)

    Widget child = OrderListItem(
      key: ValueKey(order.orderId),
      order: order,
      // Disable interaction for background cards
      onSkip: isTop && order.computedStatus.name == OrderStatus.scheduled.name
          ? () => _handleSkip(order)
          : null,
      onTap: isTop
          ? () async {
              if (order.status != OrderStatus.scheduled.name) {
                await Navigator.pushNamed(
                  context,
                  HomeRouter.orderDetail,
                  arguments: order,
                );
                if (context.mounted) {
                  context.read<HomeBloc>().add(
                    GetOrdersEvent(agentId: widget.deliveryAgentId),
                  );
                }
              }
            }
          : () {}, // No-op for background
    );

    // If background, wrap in AbsorbPointer to ensure no interaction
    if (!isTop) {
      child = AbsorbPointer(child: child);
    }

    return Transform.translate(
      offset: Offset(0, transY),
      child: Transform.scale(scale: scale, child: child),
    );
  }
}
