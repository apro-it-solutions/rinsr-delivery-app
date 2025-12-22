import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/get_orders_entity.dart';

abstract class HomeRepository {
  Future<Either<Failure, GetOrdersEntity>> getOrders();
}
