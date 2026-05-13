import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/get_agent_entity.dart';

import '../../domain/usecases/get_agent_details.dart';
import '../../domain/usecases/toggle_active.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetAgentDetails getAgentDetails;
  final ToggleActive toggleActive;

  ProfileBloc({required this.getAgentDetails, required this.toggleActive})
    : super(ProfileInitial()) {
    on<GetAgentDetailsEvent>(_getAgentDetails);
    on<LogoutEvent>(handleLogout);
    on<ToggleActiveEvent>(_toggleActive);
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

  FutureOr<void> _toggleActive(
    ToggleActiveEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    emit(ToggleActiveLoadingState(isActive: event.isActive));
    final result = await toggleActive.call(
      ToggleActiveParams(isActive: event.isActive),
    );
    result.fold(
      (failure) {
        emit(ToggleActiveErrorState(message: failure.message));
        if (currentState is ProfileDetailsLoadedState) {
          emit(currentState);
        }
      },
      (success) {
        final newIsActive =
            success.deliveryPartner?.isActive ?? event.isActive;
        emit(
          ToggleActiveSuccessState(
            isActive: newIsActive,
            message: success.message ?? 'Status updated',
          ),
        );
        if (currentState is ProfileDetailsLoadedState) {
          emit(
            ProfileDetailsLoadedState(
              agentEntity: _withUpdatedIsActive(
                currentState.agentEntity,
                newIsActive,
              ),
            ),
          );
        }
      },
    );
  }

  GetAgentEntity _withUpdatedIsActive(GetAgentEntity entity, bool isActive) {
    final data = entity.data;
    if (data == null) return entity;
    final basic = data.basicInfo;
    final updatedBasic = BasicInfoEntity(
      id: basic?.id,
      fullName: basic?.fullName,
      phoneNumber: basic?.phoneNumber,
      photo: basic?.photo,
      currentAddress: basic?.currentAddress,
      vehicleType: basic?.vehicleType,
      vehicleDetails: basic?.vehicleDetails,
      availability: basic?.availability,
      preferredZones: basic?.preferredZones,
      status: basic?.status,
      isActive: isActive,
      memberSince: basic?.memberSince,
    );
    return GetAgentEntity(
      success: entity.success,
      data: ProfileDataEntity(
        basicInfo: updatedBasic,
        payoutDetails: data.payoutDetails,
        dailyHistory: data.dailyHistory,
        invoices: data.invoices,
      ),
    );
  }
}
