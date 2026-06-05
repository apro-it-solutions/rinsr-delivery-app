import 'package:equatable/equatable.dart';

/// Payment QR for Pay-On-Delivery collection (client issues #9 / #21).
///
/// Either [qrString] (a UPI / Razorpay payment link rendered as a QR on the
/// device) or [qrImageUrl] (a server-rendered QR image) is expected to be
/// populated; the UI prefers [qrString].
class PaymentQrResponseEntity extends Equatable {
  final bool? success;
  final String? qrString;
  final String? qrImageUrl;
  final num? amount;
  final String? message;

  const PaymentQrResponseEntity({
    this.success,
    this.qrString,
    this.qrImageUrl,
    this.amount,
    this.message,
  });

  bool get hasRenderableQr =>
      (qrString != null && qrString!.isNotEmpty) ||
      (qrImageUrl != null && qrImageUrl!.isNotEmpty);

  @override
  List<Object?> get props => [success, qrString, qrImageUrl, amount, message];
}
