import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/payment_qr_response_entity.dart';
import '../repositories/order_repository.dart';

class GetPaymentQr
    extends UseCase<Either<Failure, PaymentQrResponseEntity>, String> {
  final OrderRepository orderRepository;
  GetPaymentQr(this.orderRepository);

  @override
  Future<Either<Failure, PaymentQrResponseEntity>> call(String params) {
    return orderRepository.getPaymentQr(params);
  }
}
