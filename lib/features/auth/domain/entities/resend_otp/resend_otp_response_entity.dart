import 'package:equatable/equatable.dart';

class ResendOtpResponseEntity extends Equatable {
  final String? message;

  const ResendOtpResponseEntity({this.message});

  @override
  List<Object?> get props => [message];

  @override
  bool get stringify => true;
}
