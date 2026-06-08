import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_alerts.dart';
import '../bloc/order_bloc.dart';

/// Full-screen Pay-On-Delivery QR (client issues #9 / #21).
///
/// The delivery form preloads the QR via [LoadPaymentQr] and opens this screen
/// from a button, so the customer gets a large, easy-to-scan code instead of
/// the cramped inline card. Closes itself automatically once the order's
/// payment_status flips to 'paid'.
class PaymentQrScreen extends StatelessWidget {
  /// Fallback amount when the QR payload doesn't carry one.
  final num amount;

  const PaymentQrScreen({super.key, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.greyTextColor,
        title: const Text('Collect Payment'),
      ),
      body: BlocConsumer<OrderBloc, OrderState>(
        listenWhen: (previous, current) =>
            current is OrderLoaded && current.order.paymentStatus == 'paid',
        listener: (context, state) {
          // Payment landed (poll on the delivery form flipped the status) —
          // close the QR and let the form unlock Confirm Delivery.
          AppAlerts.showSuccessSnackBar(
            context: context,
            message: 'Payment received successfully!',
          );
          Navigator.of(context).pop();
        },
        builder: (context, state) {
          final loaded = state is OrderLoaded ? state : null;
          final qr = loaded?.paymentQr;
          final displayAmount = qr?.amount ?? amount;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '₹$displayAmount',
                    style: AppTextStyles.largeTextStyle(
                      context,
                    ).copyWith(fontWeight: FontWeight.bold, fontSize: 36),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ask the customer to scan & pay.\nThis screen closes automatically once paid.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.mediumTextStyle(
                      context,
                    ).copyWith(color: AppColors.greyTextColor),
                  ),
                  const SizedBox(height: 16),
                  // Let the QR take all remaining vertical space.
                  Expanded(child: Center(child: _buildQrBody(context, loaded))),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQrBody(BuildContext context, OrderLoaded? loaded) {
    final qr = loaded?.paymentQr;

    if (loaded?.isPaymentQrLoading ?? false) {
      return const Center(child: CircularProgressIndicator());
    }
    if (qr != null && qr.qrString != null) {
      // Fill whichever dimension is smaller so the code is as large as
      // possible while staying square and fully on-screen.
      return LayoutBuilder(
        builder: (context, constraints) {
          final side = constraints.biggest.shortestSide;
          return QrImageView(
            data: qr.qrString!,
            size: side,
            backgroundColor: Colors.white,
          );
        },
      );
    }
    if (qr != null && qr.qrImageUrl != null) {
      return Image.network(
        qr.qrImageUrl!,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            _qrError(context, loaded?.paymentQrError),
      );
    }
    return _qrError(context, loaded?.paymentQrError);
  }

  Widget _qrError(BuildContext context, String? message) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.qr_code_2, size: 64, color: AppColors.greyTextColor),
        const SizedBox(height: 12),
        Text(
          message ?? 'Payment QR unavailable. Retry, or collect cash.',
          textAlign: TextAlign.center,
          style: AppTextStyles.mediumTextStyle(context),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () => context.read<OrderBloc>().add(
            const LoadPaymentQr(forceRefresh: true),
          ),
          icon: const Icon(Icons.refresh),
          label: const Text('Retry'),
        ),
      ],
    );
  }
}
