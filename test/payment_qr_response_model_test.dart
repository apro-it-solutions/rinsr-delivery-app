import 'package:flutter_test/flutter_test.dart';
import 'package:rinsr_delivery_partner/features/order/data/models/payment_qr_response_model.dart';

void main() {
  group('PaymentQrResponseModel.fromJson', () {
    test('parses root-level qr_string payload', () {
      final model = PaymentQrResponseModel.fromJson(const {
        'success': true,
        'qr_string': 'upi://pay?pa=test@upi&am=2112',
        'amount': 2112,
      });
      expect(model.success, isTrue);
      expect(model.qrString, 'upi://pay?pa=test@upi&am=2112');
      expect(model.amount, 2112);
      expect(model.hasRenderableQr, isTrue);
    });

    test('parses nested data payload with payment_link + image url', () {
      final model = PaymentQrResponseModel.fromJson(const {
        'success': true,
        'data': {
          'payment_link': 'https://rzp.io/i/abc123',
          'qr_image_url': 'https://example.com/qr.png',
          'amount': 694.5,
        },
      });
      expect(model.qrString, 'https://rzp.io/i/abc123');
      expect(model.qrImageUrl, 'https://example.com/qr.png');
      expect(model.amount, 694.5);
    });

    test('empty payload has no renderable QR', () {
      final model = PaymentQrResponseModel.fromJson(const {'success': false});
      expect(model.hasRenderableQr, isFalse);
    });
  });
}
