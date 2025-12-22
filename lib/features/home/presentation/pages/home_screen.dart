import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rinsr_delivery_partner/core/services/shared_preferences_service.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/constants/status_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/home_bloc.dart';
import '../home_router.dart';
import '../widgets/order_list_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String? deliveryAgentId = SharedPreferencesService.getString(
    AppConstants.kAgentId,
  );
  final Set<String> _skippedOrderIds = {};

  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(GetOrdersEvent(agentId: deliveryAgentId));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          leading: const SizedBox(),
          title: const Text('Available Orders'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                Navigator.pushNamed(context, HomeRouter.profile);
              },
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _skippedOrderIds.clear();
            });
            context.read<HomeBloc>().add(
              GetOrdersEvent(agentId: deliveryAgentId),
            );
          },
          child: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              if (state is HomeLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is HomeError) {
                return LayoutBuilder(
                  builder: (context, constraints) => SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: constraints.maxHeight,
                      child: const Center(
                        child: Text('Please try again later'),
                      ),
                    ),
                  ),
                );
              }
              if (state is HomeLoaded) {
                final deliveryOrders = state.filteredOrders;
                final selectedFilter = state.selectedFilter;

                return Column(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          FilterChip(
                            label: const Text('All'),
                            selectedColor: AppColors.primary,
                            selected: selectedFilter == null,
                            onSelected: (selected) {
                              if (selected) {
                                context.read<HomeBloc>().add(
                                  const FilterOrdersEvent(null),
                                );
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          ...DeliveryAgentStatus.values
                              .where(
                                (status) =>
                                    status != DeliveryAgentStatus.unknown &&
                                    status != DeliveryAgentStatus.transit,
                              )
                              .map(
                                (status) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: FilterChip(
                                    selectedColor: AppColors.primary,
                                    label: Text(status.label),
                                    selected: selectedFilter == status,
                                    onSelected: (selected) {
                                      context.read<HomeBloc>().add(
                                        FilterOrdersEvent(
                                          selected ? status : null,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          final visibleOrders = deliveryOrders
                              .where(
                                (o) => !_skippedOrderIds.contains(o.orderId),
                              )
                              .toList();

                          if (visibleOrders.isEmpty) {
                            return LayoutBuilder(
                              builder: (context, constraints) => ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: [
                                  SizedBox(
                                    height: constraints.maxHeight,
                                    child: const Center(
                                      child: Text('No orders available'),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          final currentOrder = visibleOrders.first;

                          return SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: OrderListItem(
                              key: ValueKey(currentOrder.orderId),
                              order: currentOrder,
                              onSkip:
                                  currentOrder.computedStatus.name ==
                                      OrderStatus.scheduled.name
                                  ? () {
                                      setState(() {
                                        if (currentOrder.orderId != null) {
                                          _skippedOrderIds.add(
                                            currentOrder.orderId!,
                                          );
                                        }
                                      });
                                    }
                                  : null,
                              onTap: () async {
                                if (currentOrder.status !=
                                    OrderStatus.scheduled.name) {
                                  await Navigator.pushNamed(
                                    context,
                                    HomeRouter.orderDetail,
                                    arguments: currentOrder,
                                  );
                                  if (context.mounted) {
                                    context.read<HomeBloc>().add(
                                      GetOrdersEvent(agentId: deliveryAgentId),
                                    );
                                  }
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              }
              return LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: constraints.maxHeight,
                    child: const Center(child: Text('No orders available')),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
