import 'package:json_annotation/json_annotation.dart';

import '../../../domain/entities/get_orders_entity.dart';
import 'order.dart';

part 'get_orders_model.g.dart';

@JsonSerializable()
class GetOrdersModel extends GetOrdersEntity {
  @override
  final bool? success;
  @override
  final int? count;
  @override
  final List<Order>? orders;

  const GetOrdersModel({this.success, this.count, this.orders});

  factory GetOrdersModel.fromJson(Map<String, dynamic> json) {
    return _$GetOrdersModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$GetOrdersModelToJson(this);

  GetOrdersModel copyWith({bool? success, int? count, List<Order>? orders}) {
    return GetOrdersModel(
      success: success ?? this.success,
      count: count ?? this.count,
      orders: orders ?? this.orders,
    );
  }
}
