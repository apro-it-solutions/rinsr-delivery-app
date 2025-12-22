import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_handler.dart';
import '../../../../core/network/network_info.dart';
import '../data_sources/home_remote_data_source.dart';
import '../../domain/entities/get_orders_entity.dart';
import '../../domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final ApiHandler apiHandler;
  final NetworkInfo networkInfo;
  final HomeRemoteDataSource homeRemoteDataSource;

  HomeRepositoryImpl(
    this.apiHandler,
    this.networkInfo,
    this.homeRemoteDataSource,
  );

  @override
  Future<Either<Failure, GetOrdersEntity>> getOrders() async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    return apiHandler.execute(() async {
      final model = await homeRemoteDataSource.getOrders();

      return model;
    });
  }
}
