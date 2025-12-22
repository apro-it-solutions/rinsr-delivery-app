part of 'home_bloc.dart';

sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

sealed class HomeActionState extends HomeState {
  const HomeActionState();

  @override
  List<Object> get props => [];
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

final class HomeError extends HomeState {
  final String message;
  const HomeError({required this.message});
}
