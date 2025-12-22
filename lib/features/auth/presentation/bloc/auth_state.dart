import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

abstract class AuthActionState extends AuthState {
  const AuthActionState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class NavigateOtpScreenState extends AuthActionState {
  final String phoneNumber;

  const NavigateOtpScreenState({required this.phoneNumber});

  @override
  List<Object> get props => [phoneNumber];
}

class AuthOtpSent extends AuthState {
  final int timerValue;
  final String phoneNumber;
  final String? errorMessage;

  const AuthOtpSent({
    required this.timerValue,
    required this.phoneNumber,
    this.errorMessage,
  });

  @override
  List<Object> get props => [
    timerValue,
    phoneNumber,
    if (errorMessage != null) errorMessage!,
  ];
}

class ErrorSnackBarState extends AuthActionState {
  final String message;

  const ErrorSnackBarState(this.message);

  @override
  List<Object> get props => [message];
}

class AuthVerified extends AuthState {
  final String message;

  const AuthVerified(this.message);

  @override
  List<Object> get props => [message];
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}
