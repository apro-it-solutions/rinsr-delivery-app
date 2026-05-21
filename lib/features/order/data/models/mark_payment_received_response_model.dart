import '../../domain/entities/mark_payment_received_response_entity.dart';

class MarkPaymentReceivedResponseModel
    extends MarkPaymentReceivedResponseEntity {
  const MarkPaymentReceivedResponseModel({
    super.success,
    super.message,
    super.paymentStatus,
  });

  factory MarkPaymentReceivedResponseModel.fromJson(Map<String, dynamic> json) {
    final order = json['order'];
    return MarkPaymentReceivedResponseModel(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      paymentStatus: order is Map<String, dynamic>
          ? order['payment_status'] as String?
          : null,
    );
  }
}
