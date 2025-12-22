import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/get_orders_entity.dart';

import '../repositories/home_repository.dart';

class GetOrders extends UseCase<Either<Failure, GetOrdersEntity>, NoParams> {
  final HomeRepository repository;

  GetOrders(this.repository);

  @override
  Future<Either<Failure, GetOrdersEntity>> call(NoParams params) async {
    return await repository.getOrders();
  }
}
