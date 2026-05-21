import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/mark_payment_received_response_entity.dart';
import '../repositories/order_repository.dart';

class MarkPaymentReceived
    extends
        UseCase<Either<Failure, MarkPaymentReceivedResponseEntity>, String> {
  final OrderRepository orderRepository;
  MarkPaymentReceived(this.orderRepository);

  @override
  Future<Either<Failure, MarkPaymentReceivedResponseEntity>> call(
    String params,
  ) {
    return orderRepository.markPaymentReceived(params);
  }
}
