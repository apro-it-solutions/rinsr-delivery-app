import '../../domain/entities/payment_qr_response_entity.dart';

class PaymentQrResponseModel extends PaymentQrResponseEntity {
  const PaymentQrResponseModel({
    super.success,
    super.qrString,
    super.qrImageUrl,
    super.amount,
    super.message,
  });

  /// Tolerant of contract drift while the backend endpoint stabilises:
  /// the payload may arrive at the root or under `data`/`qr`, and the link
  /// and image keys have a few plausible spellings.
  factory PaymentQrResponseModel.fromJson(Map<String, dynamic> json) {
    final body = switch (json) {
      {'data': final Map<String, dynamic> data} => data,
      {'qr': final Map<String, dynamic> qr} => qr,
      _ => json,
    };

    String? firstString(List<String> keys) {
      for (final key in keys) {
        final value = body[key];
        if (value is String && value.isNotEmpty) return value;
      }
      return null;
    }

    return PaymentQrResponseModel(
      success: json['success'] as bool?,
      qrString: firstString([
        'qr_string',
        'upi_link',
        'payment_link',
        'short_url',
      ]),
      qrImageUrl: firstString(['qr_image_url', 'qr_url', 'image_url']),
      amount: body['amount'] as num?,
      message: json['message'] as String?,
    );
  }
}
