import 'package:equatable/equatable.dart';

class ResendOtpRequestEntity extends Equatable {
  final String? phone;

  const ResendOtpRequestEntity({required this.phone});

  @override
  List<Object?> get props => [phone];

  @override
  bool get stringify => true;
}
