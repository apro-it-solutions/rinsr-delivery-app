import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/get_agent_entity.dart';

import '../../domain/usecases/get_agent_details.dart';
import '../../domain/usecases/toggle_active.dart';
import '../../domain/usecases/update_profile_image.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetAgentDetails getAgentDetails;
  final ToggleActive toggleActive;
  final UpdateProfileImage updateProfileImage;

  ProfileBloc({
    required this.getAgentDetails,
    required this.toggleActive,
    required this.updateProfileImage,
  }) : super(ProfileInitial()) {
    on<GetAgentDetailsEvent>(_getAgentDetails);
    on<LogoutEvent>(handleLogout);
    on<ToggleActiveEvent>(_toggleActive);
    on<UpdateProfileImageEvent>(_updateProfileImage);
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

  FutureOr<void> _updateProfileImage(
    UpdateProfileImageEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    emit(UpdateProfileImageLoadingState());
    final result = await updateProfileImage.call(
      UpdateProfileImageParams(filePath: event.filePath),
    );
    result.fold(
      (failure) {
        emit(UpdateProfileImageErrorState(message: failure.message));
        if (currentState is ProfileDetailsLoadedState) {
          emit(currentState);
        }
      },
      (success) {
        emit(
          UpdateProfileImageSuccessState(
            message: success.message ?? 'Profile image updated.',
            photoUrl: success.photoUrl,
          ),
        );
        if (currentState is ProfileDetailsLoadedState &&
            success.photoUrl != null &&
            success.photoUrl!.isNotEmpty) {
          emit(
            ProfileDetailsLoadedState(
              agentEntity: _withUpdatedPhoto(
                currentState.agentEntity,
                success.photoUrl!,
              ),
            ),
          );
        } else if (currentState is ProfileDetailsLoadedState) {
          emit(currentState);
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

  GetAgentEntity _withUpdatedPhoto(GetAgentEntity entity, String photoUrl) {
    final data = entity.data;
    if (data == null) return entity;
    final basic = data.basicInfo;
    final updatedBasic = BasicInfoEntity(
      id: basic?.id,
      fullName: basic?.fullName,
      phoneNumber: basic?.phoneNumber,
      photo: photoUrl,
      currentAddress: basic?.currentAddress,
      vehicleType: basic?.vehicleType,
      vehicleDetails: basic?.vehicleDetails,
      availability: basic?.availability,
      preferredZones: basic?.preferredZones,
      status: basic?.status,
      isActive: basic?.isActive,
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
