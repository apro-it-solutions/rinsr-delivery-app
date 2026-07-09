import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/api_handler.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/app_version_entity.dart';
import '../../domain/repositories/app_version_repository.dart';
import '../data_sources/app_version_remote_data_source.dart';

class AppVersionRepositoryImpl implements AppVersionRepository {
  final AppVersionRemoteDataSource remoteDataSource;
  final ApiHandler apiHandler;
  final NetworkInfo networkInfo;

  AppVersionRepositoryImpl(
    this.remoteDataSource,
    this.apiHandler,
    this.networkInfo,
  );

  @override
  Future<Either<Failure, AppVersionEntity>> checkAppVersion() async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    return await apiHandler.execute(() {
      return remoteDataSource.checkAppVersion();
    });
  }
}
