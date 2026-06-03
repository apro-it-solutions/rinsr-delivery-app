import 'package:equatable/equatable.dart';

class CancelOrderResponseEntity extends Equatable {
  final bool? success;
  final String? message;
  final String? status;

  const CancelOrderResponseEntity({this.success, this.message, this.status});

  @override
  List<Object?> get props => [success, message, status];
}
