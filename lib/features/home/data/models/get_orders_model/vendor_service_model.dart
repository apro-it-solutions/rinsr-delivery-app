import 'package:json_annotation/json_annotation.dart';

import '../../../domain/entities/get_orders_entity.dart';

part 'vendor_service_model.g.dart';

@JsonSerializable()
class VendorServiceModel extends VendorServiceEntity {
  @override
  final String? name;

  @override
  final num? price;

  const VendorServiceModel({this.name, this.price})
    : super(name: name, price: price);

  factory VendorServiceModel.fromJson(Map<String, dynamic> json) =>
      _$VendorServiceModelFromJson(json);

  Map<String, dynamic> toJson() => _$VendorServiceModelToJson(this);
}
