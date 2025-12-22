import 'package:dartz/dartz.dart';

import 'package:rinsr_delivery_partner/core/error/failures.dart';
import 'package:rinsr_delivery_partner/core/network/api_handler.dart';
import 'package:rinsr_delivery_partner/core/network/network_info.dart';

import 'package:rinsr_delivery_partner/features/profile/domain/entities/get_agent_entity.dart';

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
}
