import 'package:equatable/equatable.dart';

class MarkPaymentReceivedResponseEntity extends Equatable {
  final bool? success;
  final String? message;
  final String? paymentStatus;

  const MarkPaymentReceivedResponseEntity({
    this.success,
    this.message,
    this.paymentStatus,
  });

  @override
  List<Object?> get props => [success, message, paymentStatus];
}
