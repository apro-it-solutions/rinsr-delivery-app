import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class NavigatedOtpScreenEvent extends AuthEvent {
  final String phoneNumber;

  const NavigatedOtpScreenEvent(this.phoneNumber);

  @override
  List<Object> get props => [phoneNumber];
}

class AuthSendOtp extends AuthEvent {
  final String phoneNumber;

  const AuthSendOtp(this.phoneNumber);

  @override
  List<Object> get props => [phoneNumber];
}

class AuthVerifyOtp extends AuthEvent {
  final String otp;
  final String phoneNumber;

  const AuthVerifyOtp({required this.otp, required this.phoneNumber});

  @override
  List<Object> get props => [otp, phoneNumber];
}

class AuthResendOtp extends AuthEvent {
  final String phoneNumber;

  const AuthResendOtp(this.phoneNumber);

  @override
  List<Object> get props => [phoneNumber];
}

class AuthTimerTicked extends AuthEvent {
  final int duration;

  const AuthTimerTicked(this.duration);

  @override
  List<Object> get props => [duration];
}
