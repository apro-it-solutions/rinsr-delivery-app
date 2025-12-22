import 'package:equatable/equatable.dart';

class UpdateOrderParams extends Equatable {
  final String orderId;
  final String status;
  final double? weight;
  final String? photoPath;
  final int? noOfClothes;

  const UpdateOrderParams({
    required this.orderId,
    required this.status,
    this.weight,
    this.photoPath,
    this.noOfClothes,
  });

  @override
  List<Object?> get props => [orderId, status, weight, photoPath, noOfClothes];
}
