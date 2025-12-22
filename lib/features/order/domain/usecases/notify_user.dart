import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/notify_user_response_entity.dart';

import '../repositories/order_repository.dart';

class NotifyUser
    extends UseCase<Either<Failure, NotifyUserResponseEntity>, String> {
  final OrderRepository orderRepository;
  NotifyUser(this.orderRepository);
  @override
  Future<Either<Failure, NotifyUserResponseEntity>> call(String params) {
    return orderRepository.notifyUser(params);
  }
}
