import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/accept_order_params.dart';
import '../entities/accept_order_response_entity.dart';
import '../repositories/order_repository.dart';

class AcceptOrder
    extends
        UseCase<Either<Failure, AcceptOrderResponseEntity>, AcceptOrderParams> {
  final OrderRepository repository;

  AcceptOrder(this.repository);

  @override
  Future<Either<Failure, AcceptOrderResponseEntity>> call(
    AcceptOrderParams params,
  ) {
    return repository.acceptOrder(params.orderId, params.type);
  }
}
