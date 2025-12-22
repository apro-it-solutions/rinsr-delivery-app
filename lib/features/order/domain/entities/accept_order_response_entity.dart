import 'package:equatable/equatable.dart';

class AcceptOrderResponseEntity extends Equatable {
  final bool? success;
  final String? message;
  const AcceptOrderResponseEntity({
    required this.success,
    required this.message,
  });
  @override
  List<Object?> get props => [success, message];
}
