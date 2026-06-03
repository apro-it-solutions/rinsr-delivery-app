import '../../domain/entities/cancel_order_response_entity.dart';

class CancelOrderResponseModel extends CancelOrderResponseEntity {
  const CancelOrderResponseModel({super.success, super.message, super.status});

  factory CancelOrderResponseModel.fromJson(Map<String, dynamic> json) {
    final order = json['order'];
    return CancelOrderResponseModel(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      status: order is Map<String, dynamic>
          ? order['status'] as String?
          : json['status'] as String?,
    );
  }
}
