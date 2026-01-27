import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/shared_preferences_service.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/constants/status_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/get_orders_entity.dart';
import '../bloc/home_bloc.dart';
import '../home_router.dart';
import '../widgets/order_list_item.dart';
import '../widgets/single_order_view.dart';
import '../../../../core/services/fcm_service.dart';
import 'dart:async';
import '../widgets/new_order_request_view.dart';
import '../../../order/domain/entities/accept_order_params.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final String? deliveryAgentId = SharedPreferencesService.getString(
    AppConstants.kAgentId,
  );
  final Set<String> _skippedOrderIds = {};
  String? _pendingNavigationOrderId;
  // Track the currently open transit order to prevent double navigation
  String? _activeTransitOrderId;
  StreamSubscription? _orderSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    context.read<HomeBloc>().add(GetOrdersEvent(agentId: deliveryAgentId));

    // Listen for new orders
    _orderSubscription = FCMService.orderStream.listen((data) {
      if (mounted) {
        _showNewOrderBottomSheet(data);
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Always refresh list on resume as well
      context.read<HomeBloc>().add(GetOrdersEvent(agentId: deliveryAgentId));
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _orderSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: BlocListener<HomeBloc, HomeState>(
        listener: (context, state) {
          if (state is HomeAcceptOrder) {
            _pendingNavigationOrderId = state.order.orderId;
          }

          if (state is HomeLoaded) {
            // Check for pending navigation for accepted order
            if (_pendingNavigationOrderId != null) {
              final targetOrder = state.allOrders
                  .where((o) => o.orderId == _pendingNavigationOrderId)
                  .firstOrNull;
              if (targetOrder != null) {
                print('hello2');
                _pendingNavigationOrderId = null;
                Navigator.pushNamed(
                  context,
                  HomeRouter.orderDetail,
                  arguments: targetOrder,
                );
                return; // Prioritize this navigation
              }
            }

            // Check for Transit order to force navigation
            final transitOrder = state.allOrders.where((o) {
              return o.computedStatus.agentStatus ==
                  DeliveryAgentStatus.transit;
            }).firstOrNull;

            if (transitOrder != null &&
                context.mounted &&
                _activeTransitOrderId != transitOrder.orderId) {
              _activeTransitOrderId = transitOrder.orderId;
              print(
                'Forcing navigation to transit order: ${transitOrder.orderId}',
              );
              Navigator.pushNamed(
                context,
                HomeRouter.orderDetail,
                arguments: transitOrder,
              ).then((_) {
                _activeTransitOrderId = null;
              });
            }
          }
        },
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (state is HomeLoaded) {
              final visibleOrders = state.filteredOrders.where((o) {
                return !_skippedOrderIds.contains(o.orderId);
              }).toList();

              // Check if we should show the Single Order View
              final isHistory =
                  state.selectedFilter == DeliveryAgentStatus.delivered ||
                  state.selectedFilter == DeliveryAgentStatus.cancelled;
              if (!isHistory) {
                final pendingOrders = visibleOrders.where((o) {
                  return o.computedStatus.agentStatus ==
                      DeliveryAgentStatus.accepted;
                }).toList();
                // For active tabs (Pickup, Accepted, etc.), show one card at a time.
                return _buildSingleOrderView(state, pendingOrders);
              }

              // Otherwise, show the Standard History/Active List
              return _buildStandardListView(state, visibleOrders);
            }

            return _buildErrorView();
          },
        ),
      ),
    );
  }

  void _showNewOrderBottomSheet(Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      barrierLabel: 'New Order',
      builder: (context) {
        return NewOrderRequestView(
          data: data,
          onSkip: () => Navigator.pop(context),
          onAccept: () {
            final orderId = data['orderId'];
            if (orderId != null) {
              context.read<HomeBloc>().add(
                AcceptOrderEvent(
                  params: AcceptOrderParams(orderId: orderId, type: 'pickup'),
                ),
              );
            }
            Navigator.pop(context); // Close overlay
            // Refresh explicitly
            context.read<HomeBloc>().add(
              GetOrdersEvent(agentId: deliveryAgentId),
            );
          },
        );
      },
    );
  }

  Widget _buildStandardListView(
    HomeLoaded state,
    List<OrderDetailsEntity> visibleOrders,
  ) {
    return Scaffold(
      appBar: AppBar(
        leading: const SizedBox(),
        title: const Text('My Deliveries'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, HomeRouter.profile),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return RefreshIndicator(
            onRefresh: () async {
              setState(() => _skippedOrderIds.clear());
              context.read<HomeBloc>().add(
                GetOrdersEvent(agentId: deliveryAgentId),
              );
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  children: [
                    _buildFilterChips(state),
                    if (visibleOrders.isEmpty)
                      SizedBox(
                        height: constraints.maxHeight * 0.7,
                        child: const Center(child: Text('No orders available')),
                      )
                    else
                      ListView.separated(
                        padding: const EdgeInsets.all(16),
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: visibleOrders.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final order = visibleOrders[index];
                          return OrderListItem(
                            key: ValueKey(order.orderId),
                            order: order,
                            onTap: () async {
                              await Navigator.pushNamed(
                                context,
                                HomeRouter.orderDetail,
                                arguments: order,
                              );
                              if (context.mounted) {
                                context.read<HomeBloc>().add(
                                  GetOrdersEvent(agentId: deliveryAgentId),
                                );
                              }
                            },
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChips(HomeLoaded state) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          ...DeliveryAgentStatus.values
              .where(
                (status) =>
                    status != DeliveryAgentStatus.unknown &&
                    status != DeliveryAgentStatus.pickup &&
                    status != DeliveryAgentStatus.transit,
              )
              .map(
                (status) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selectedColor: AppColors.primary,
                    label: Text(status.label),
                    selected: state.selectedFilter == status,
                    onSelected: (selected) {
                      context.read<HomeBloc>().add(
                        FilterOrdersEvent(filter: status),
                      );
                    },
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildSingleOrderView(
    HomeLoaded state,
    List<OrderDetailsEntity> visibleOrders,
  ) {
    if (visibleOrders.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          leading: const SizedBox(),
          title: const Text('My Deliveries'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () => Navigator.pushNamed(context, HomeRouter.profile),
            ),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return RefreshIndicator(
              onRefresh: () async {
                setState(() => _skippedOrderIds.clear());
                context.read<HomeBloc>().add(
                  GetOrdersEvent(agentId: deliveryAgentId),
                );
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    children: [
                      _buildFilterChips(state),
                      SizedBox(
                        height: constraints.maxHeight * 0.7,
                        child: const Center(child: Text('No orders available')),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    final currentOrder = visibleOrders.first;

    return Scaffold(
      appBar: AppBar(
        leading: const SizedBox(),
        title: const Text('My Deliveries'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, HomeRouter.profile),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(state),
          Expanded(
            child: SingleOrderView(
              order: currentOrder,
              onRefresh: () async {
                setState(() => _skippedOrderIds.clear());
                context.read<HomeBloc>().add(
                  GetOrdersEvent(agentId: deliveryAgentId),
                );
              },
              onSkip: () {
                if (currentOrder.orderId != null) {
                  setState(() {
                    _skippedOrderIds.add(currentOrder.orderId!);
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Please try again later'),
            TextButton(
              onPressed: () => context.read<HomeBloc>().add(
                GetOrdersEvent(agentId: deliveryAgentId),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
