import 'package:dartz/dartz.dart';
import 'package:rinsr_delivery_partner/core/usecases/usecase.dart';

import '../../../../core/error/failures.dart';
import '../entities/update_order_params.dart';
import '../entities/update_order_response_entity.dart';
import '../repositories/order_repository.dart';

class UpdateOrder
    extends
        UseCase<Either<Failure, UpdateOrderResponseEntity>, UpdateOrderParams> {
  final OrderRepository orderRepository;
  UpdateOrder(this.orderRepository);
  @override
  Future<Either<Failure, UpdateOrderResponseEntity>> call(
    UpdateOrderParams params,
  ) async {
    return await orderRepository.updateOrder(params);
  }
}
