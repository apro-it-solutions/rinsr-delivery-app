import 'package:json_annotation/json_annotation.dart';
import 'package:rinsr_delivery_partner/features/order/domain/entities/update_order_response_entity.dart';

import 'order.dart';

part 'update_order_model.g.dart';

@JsonSerializable()
class UpdateOrderModel extends UpdateOrderResponseEntity {
  @override
  final bool? success;
  @override
  final String? message;
  @override
  final Order? order;

  const UpdateOrderModel({this.success, this.message, this.order})
    : super(success: success, message: message, order: order);

  factory UpdateOrderModel.fromJson(Map<String, dynamic> json) {
    return _$UpdateOrderModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$UpdateOrderModelToJson(this);

  UpdateOrderModel copyWith({bool? success, String? message, Order? order}) {
    return UpdateOrderModel(
      success: success ?? this.success,
      message: message ?? this.message,
      order: order ?? this.order,
    );
  }
}
