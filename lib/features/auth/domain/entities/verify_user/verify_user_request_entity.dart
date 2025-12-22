import 'package:equatable/equatable.dart';

class VerifyOtpRequestEntity extends Equatable {
  final String? phone;
  final String? otp;

  const VerifyOtpRequestEntity({this.phone, this.otp});

  @override
  List<Object?> get props => [phone, otp];

  @override
  bool get stringify => true;
}
