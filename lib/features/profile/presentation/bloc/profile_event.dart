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

final class ToggleActiveEvent extends ProfileEvent {
  final bool isActive;

  const ToggleActiveEvent({required this.isActive});

  @override
  List<Object> get props => [isActive];
}

final class UpdateProfileImageEvent extends ProfileEvent {
  final String filePath;

  const UpdateProfileImageEvent({required this.filePath});

  @override
  List<Object> get props => [filePath];
}
