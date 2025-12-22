import 'package:json_annotation/json_annotation.dart';

import '../../../../home/domain/entities/get_orders_entity.dart';

part 'service_id.g.dart';

@JsonSerializable()
class ServiceId extends ServiceIdEntity {
  @override
  @JsonKey(name: '_id')
  final String? id;
  @override
  final String? name;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
  @override
  @JsonKey(name: '__v')
  final int? v;
  @override
  final int? price;

  const ServiceId({
    this.id,
    this.name,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.price,
  }) : super(
         id: id,
         name: name,
         createdAt: createdAt,
         updatedAt: updatedAt,
         v: v,
         price: price,
       );

  factory ServiceId.fromJson(Map<String, dynamic> json) {
    return _$ServiceIdFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ServiceIdToJson(this);

  ServiceId copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? v,
    int? price,
  }) {
    return ServiceId(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      v: v ?? this.v,
      price: price ?? this.price,
    );
  }
}
