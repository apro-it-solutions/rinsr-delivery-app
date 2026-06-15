import 'package:flutter_test/flutter_test.dart';
import 'package:rinsr_delivery_partner/features/home/domain/entities/get_orders_entity.dart';

void main() {
  group('OrderDetailsEntity.isPayOnDelivery', () {
    // Regression: the gate was hardcoded to paymentMethod == 'pay_on_delivery',
    // but the backend sends a cash-on-delivery code ('cod'/'cash'); prepaid
    // orders come through as 'online'. The mismatch meant the "Show Payment QR"
    // button never rendered. (client issues #9 / #21)
    OrderDetailsEntity order(String? method) =>
        OrderDetailsEntity(paymentMethod: method);

    test('true for common cash-on-delivery spellings', () {
      for (final m in [
        'cod',
        'COD',
        'cash',
        'Cash',
        'cash_on_delivery',
        'cash-on-delivery',
        'pay_on_delivery',
        'pod',
        ' cod ',
      ]) {
        expect(order(m).isPayOnDelivery, isTrue, reason: 'expected POD for "$m"');
      }
    });

    test('false for prepaid / gateway / unknown methods', () {
      for (final m in ['online', 'prepaid', 'razorpay', '', null]) {
        expect(order(m).isPayOnDelivery, isFalse,
            reason: 'expected NOT POD for "$m"');
      }
    });
  });
}
