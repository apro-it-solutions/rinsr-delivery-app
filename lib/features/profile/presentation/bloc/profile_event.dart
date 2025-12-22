part of 'profile_bloc.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

final class GetAgentDetailsEvent extends ProfileEvent {
  final String id;

  const GetAgentDetailsEvent(this.id);

  @override
  List<Object> get props => [id];
}

final class LogoutEvent extends ProfileEvent {}
