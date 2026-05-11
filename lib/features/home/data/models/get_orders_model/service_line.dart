import 'package:json_annotation/json_annotation.dart';

import '../../../domain/entities/get_orders_entity.dart';
import 'service_item.dart';

part 'service_line.g.dart';

@JsonSerializable()
class ServiceLine extends ServiceLineEntity {
  @override
  @JsonKey(name: 'service_id')
  final String? serviceId;
  @override
  @JsonKey(name: 'service_name')
  final String? serviceName;
  @override
  final List<ServiceItem>? items;
  @override
  final num? subtotal;
  @override
  @JsonKey(name: '_id')
  final String? id;

  const ServiceLine({
    this.serviceId,
    this.serviceName,
    this.items,
    this.subtotal,
    this.id,
  }) : super(
         serviceId: serviceId,
         serviceName: serviceName,
         items: items,
         subtotal: subtotal,
         id: id,
       );

  factory ServiceLine.fromJson(Map<String, dynamic> json) =>
      _$ServiceLineFromJson(json);

  Map<String, dynamic> toJson() => _$ServiceLineToJson(this);
}
