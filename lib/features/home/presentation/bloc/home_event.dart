part of 'home_bloc.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

final class GetOrdersEvent extends HomeEvent {
  final String? agentId;
  const GetOrdersEvent({this.agentId});
}

final class FilterOrdersEvent extends HomeEvent {
  final DeliveryAgentStatus filter;
  const FilterOrdersEvent({required this.filter});

  @override
  List<Object> get props => [filter];
}

final class AcceptOrderEvent extends HomeEvent {
  final AcceptOrderParams params;
  const AcceptOrderEvent({required this.params});

  @override
  List<Object> get props => [params];
}
