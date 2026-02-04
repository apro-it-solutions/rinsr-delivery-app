import 'package:equatable/equatable.dart';

class UpdateOrderParams extends Equatable {
  final String orderId;
  final String status;
  final String? weight;
  final String? photoPath;
  final int? noOfClothes;
  final String? barcode;

  const UpdateOrderParams({
    required this.orderId,
    required this.status,
    this.weight,
    this.photoPath,
    this.noOfClothes,
    this.barcode,
  });

  @override
  List<Object?> get props => [
    orderId,
    status,
    weight,
    photoPath,
    noOfClothes,
    barcode,
  ];
}
