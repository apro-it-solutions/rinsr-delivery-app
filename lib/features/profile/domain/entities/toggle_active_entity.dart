import 'package:equatable/equatable.dart';

class ToggleActiveEntity extends Equatable {
  final bool? success;
  final String? message;
  final ToggleActiveData? deliveryPartner;

  const ToggleActiveEntity({this.success, this.message, this.deliveryPartner});

  @override
  List<Object?> get props => [success, message, deliveryPartner];
}

class ToggleActiveData extends Equatable {
  final String? id;
  final String? fullName;
  final bool? isActive;

  const ToggleActiveData({this.id, this.fullName, this.isActive});

  @override
  List<Object?> get props => [id, fullName, isActive];
}
