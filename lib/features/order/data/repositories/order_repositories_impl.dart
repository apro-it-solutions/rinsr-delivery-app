import 'package:dartz/dartz.dart';

import 'package:rinsr_delivery_partner/core/error/failures.dart';
import 'package:rinsr_delivery_partner/core/network/api_handler.dart';
import 'package:rinsr_delivery_partner/features/order/domain/entities/accept_order_response_entity.dart';
import 'package:rinsr_delivery_partner/features/order/domain/entities/notify_user_response_entity.dart';

import 'package:rinsr_delivery_partner/features/order/domain/entities/update_order_params.dart';

import 'package:rinsr_delivery_partner/features/order/domain/entities/update_order_response_entity.dart';

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
