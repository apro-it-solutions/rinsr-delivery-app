import 'package:equatable/equatable.dart';

class NotifyUserResponseEntity extends Equatable {
  final bool? success;
  final String? message;

  const NotifyUserResponseEntity({this.success, this.message});

  @override
  List<Object?> get props => [success, message];
}
