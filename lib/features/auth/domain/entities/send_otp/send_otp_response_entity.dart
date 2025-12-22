import 'package:equatable/equatable.dart';

class SendOtpResponseEntity extends Equatable {
  final String? message;

  const SendOtpResponseEntity({this.message});

  @override
  List<Object?> get props => [message];

  @override
  bool get stringify => true;
}
