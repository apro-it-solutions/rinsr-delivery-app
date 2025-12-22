import 'package:equatable/equatable.dart';

class SendOtpRequestEntity extends Equatable {
  final String? phone;

  const SendOtpRequestEntity({this.phone});

  @override
  List<Object?> get props => [phone];

  @override
  bool get stringify => true;
}
