import 'package:equatable/equatable.dart';

class AcceptOrderParams extends Equatable {
  final String orderId;
  final String type;

  const AcceptOrderParams({required this.orderId, required this.type});

  @override
  List<Object?> get props => [orderId, type];
}
