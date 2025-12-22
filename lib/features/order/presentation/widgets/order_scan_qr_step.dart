import 'package:flutter/material.dart';
import '../../../../core/widgets/slide_action_button.dart';

class OrderScanQrStep extends StatelessWidget {
  final VoidCallback onScanCompleted;

  const OrderScanQrStep({super.key, required this.onScanCompleted});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.qr_code_scanner, size: 100, color: Colors.blue),
        const SizedBox(height: 24),
        const Text(
          'Scan Laundry Bag QR',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 32),
        SlideActionButton(
          text: 'Simulate Scan',
          onSlideCompleted: onScanCompleted,
          icon: Icons.qr_code_scanner,
        ),
      ],
    );
  }
}
