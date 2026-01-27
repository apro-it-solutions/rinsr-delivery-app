import 'package:json_annotation/json_annotation.dart';
import '../../../domain/entities/accept_order_response_entity.dart';

import 'order.dart';

part 'accept_order_response_model.g.dart';

@JsonSerializable()
class AcceptOrderResponseModel extends AcceptOrderResponseEntity {
  @override
  final bool? success;
  @override
  final String? message;
  @override
  final Order? order;

  const AcceptOrderResponseModel({this.success, this.message, this.order})
    : super(success: success, message: message, order: order);

  factory AcceptOrderResponseModel.fromJson(Map<String, dynamic> json) {
    return _$AcceptOrderResponseModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$AcceptOrderResponseModelToJson(this);

  AcceptOrderResponseModel copyWith({
    bool? success,
    String? message,
    Order? order,
  }) {
    return AcceptOrderResponseModel(
      success: success ?? this.success,
      message: message ?? this.message,
      order: order ?? this.order,
    );
  }
}
