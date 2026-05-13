import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/api_handler.dart';
import '../../../../core/network/network_info.dart';

import '../../domain/entities/get_agent_entity.dart';
import '../../domain/entities/ratings_entity.dart';
import '../../domain/entities/toggle_active_entity.dart';
import '../../domain/entities/update_profile_image_entity.dart';

import '../../domain/repositories/profile_repository.dart';
import '../data_sources/profile_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final ApiHandler apiHandler;
  final NetworkInfo networkInfo;

  ProfileRepositoryImpl(
    this.remoteDataSource,
    this.apiHandler,
    this.networkInfo,
  );

  @override
  Future<Either<Failure, GetAgentEntity>> getAgentDetails() async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    return await apiHandler.execute(() {
      return remoteDataSource.getAgentDetails();
    });
  }

  @override
  Future<Either<Failure, ToggleActiveEntity>> toggleActive({
    required bool isActive,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    return await apiHandler.execute(() {
      return remoteDataSource.toggleActive(isActive: isActive);
    });
  }

  @override
  Future<Either<Failure, RatingsEntity>> getRatings({
    required String partnerId,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    return await apiHandler.execute(() {
      return remoteDataSource.getRatings(partnerId: partnerId);
    });
  }

  @override
  Future<Either<Failure, UpdateProfileImageEntity>> updateProfileImage({
    required String filePath,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    return await apiHandler.execute(() {
      return remoteDataSource.updateProfileImage(filePath: filePath);
    });
  }
}
