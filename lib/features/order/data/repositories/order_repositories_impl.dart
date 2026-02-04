import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/api_handler.dart';
import '../../domain/entities/accept_order_response_entity.dart';
import '../../domain/entities/notify_user_response_entity.dart';

import '../../domain/entities/update_order_params.dart';

import '../../domain/entities/update_order_response_entity.dart';

import '../../../../core/network/network_info.dart';
import '../../domain/repositories/order_repository.dart';
import '../data_sources/order_remote_data_source.dart';

class OrderRepositoriesImpl implements OrderRepository {
  final ApiHandler apiHandler;
  final NetworkInfo networkInfo;
  final OrderRemoteDataSource remoteDataSource;

  OrderRepositoriesImpl(
    this.apiHandler,
    this.networkInfo,
    this.remoteDataSource,
  );
  @override
  Future<Either<Failure, UpdateOrderResponseEntity>> updateOrder(
    UpdateOrderParams params,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    return await apiHandler.execute(() async {
      return await remoteDataSource.updateOrder(
        orderId: params.orderId,
        status: params.status,
        photoPath: params.photoPath,
        weight: params.weight,
        barcode: params.barcode,
      );
    });
  }

  @override
  Future<Either<Failure, NotifyUserResponseEntity>> notifyUser(
    String orderId,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    return await apiHandler.execute(() async {
      return await remoteDataSource.notifyUsers(orderId);
    });
  }

  @override
  Future<Either<Failure, AcceptOrderResponseEntity>> acceptOrder(
    String orderId,
    String type,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    return await apiHandler.execute(() async {
      return await remoteDataSource.acceptOrder(orderId, type);
    });
  }
}
