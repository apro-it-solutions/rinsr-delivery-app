import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

import '../entities/accept_order_response_entity.dart';
import '../entities/notify_user_response_entity.dart';
import '../entities/update_order_params.dart';
import '../entities/update_order_response_entity.dart';

abstract class OrderRepository {
  Future<Either<Failure, UpdateOrderResponseEntity>> updateOrder(
    UpdateOrderParams params,
  );

  Future<Either<Failure, NotifyUserResponseEntity>> notifyUser(String orderId);
  Future<Either<Failure, AcceptOrderResponseEntity>> acceptOrder(
    String orderId,
    String type,
  );
}
