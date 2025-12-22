part of 'profile_bloc.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object> get props => [];
}

sealed class ProfileActionState extends ProfileState {
  const ProfileActionState();

  @override
  List<Object> get props => [];
}

final class ProfileInitial extends ProfileState {}

final class LogoutState extends ProfileActionState {}

final class ProfileLoadingState extends ProfileState {}

final class ProfileErrorState extends ProfileState {
  final String message;

  const ProfileErrorState({required this.message});

  @override
  List<Object> get props => [message];
}

final class ProfileDetailsLoadedState extends ProfileState {
  final GetAgentEntity agentEntity;

  const ProfileDetailsLoadedState({required this.agentEntity});

  @override
  List<Object> get props => [agentEntity];
}
