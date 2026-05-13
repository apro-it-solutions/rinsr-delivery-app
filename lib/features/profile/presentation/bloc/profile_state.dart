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

final class ToggleActiveLoadingState extends ProfileActionState {
  final bool isActive;

  const ToggleActiveLoadingState({required this.isActive});

  @override
  List<Object> get props => [isActive];
}

final class ToggleActiveSuccessState extends ProfileActionState {
  final bool isActive;
  final String message;

  const ToggleActiveSuccessState({
    required this.isActive,
    required this.message,
  });

  @override
  List<Object> get props => [isActive, message];
}

final class ToggleActiveErrorState extends ProfileActionState {
  final String message;

  const ToggleActiveErrorState({required this.message});

  @override
  List<Object> get props => [message];
}
