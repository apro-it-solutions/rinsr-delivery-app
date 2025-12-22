import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rinsr_delivery_partner/core/usecases/usecase.dart';
import 'package:rinsr_delivery_partner/features/profile/domain/entities/get_agent_entity.dart';

import '../../domain/usecases/get_agent_details.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetAgentDetails getAgentDetails;

  ProfileBloc({required this.getAgentDetails}) : super(ProfileInitial()) {
    on<GetAgentDetailsEvent>(_getAgentDetails);
    on<LogoutEvent>(handleLogout);
  }

  FutureOr<void> _getAgentDetails(
    GetAgentDetailsEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoadingState());
    final result = await getAgentDetails.call(const NoParams());
    result.fold(
      (failure) => emit(ProfileErrorState(message: failure.message)),
      (success) => emit(ProfileDetailsLoadedState(agentEntity: success)),
    );
  }

  FutureOr<void> handleLogout(LogoutEvent event, Emitter<ProfileState> emit) {
    emit(LogoutState());
  }
}
