part of 'home_bloc.dart';

sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

// Action states are for one-time UI events (like showing a dialog)
sealed class HomeActionState extends HomeState {
  const HomeActionState();
}

final class HomeInitial extends HomeState {}

final class HomeLoading extends HomeState {}

final class HomeLoaded extends HomeState {
  final List<OrderDetailsEntity> allOrders;
  final List<OrderDetailsEntity> filteredOrders;
  final DeliveryAgentStatus? selectedFilter;
  final String? agentId;

  const HomeLoaded({
    required this.allOrders,
    required this.filteredOrders,
    this.selectedFilter,
    this.agentId,
  });

  @override
  List<Object> get props => [allOrders, filteredOrders, selectedFilter ?? ''];
}

// NEW: This state triggers the full-screen "Uber-style" request
final class NewOrderIncomingState extends HomeActionState {
  final OrderDetailsEntity order;
  const NewOrderIncomingState({required this.order});

  @override
  List<Object> get props => [order];
}

final class HomeError extends HomeState {
  final String message;
  const HomeError({required this.message});
}

final class HomeAcceptOrder extends HomeActionState {
  final AcceptOrderResponseEntity order;
  const HomeAcceptOrder({required this.order});

  @override
  List<Object> get props => [order];
}
