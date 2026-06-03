import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/cancel_order_response_entity.dart';
import '../repositories/order_repository.dart';

class CancelOrderParams extends Equatable {
  final String orderId;
  final String reason;

  const CancelOrderParams({required this.orderId, required this.reason});

  @override
  List<Object?> get props => [orderId, reason];
}

class CancelOrder
    extends
        UseCase<Either<Failure, CancelOrderResponseEntity>, CancelOrderParams> {
  final OrderRepository orderRepository;
  CancelOrder(this.orderRepository);

  @override
  Future<Either<Failure, CancelOrderResponseEntity>> call(
    CancelOrderParams params,
  ) {
    return orderRepository.cancelOrder(params.orderId, params.reason);
  }
}
