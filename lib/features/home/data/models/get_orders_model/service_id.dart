import 'package:json_annotation/json_annotation.dart';

import '../../../domain/entities/get_orders_entity.dart';

part 'service_id.g.dart';

@JsonSerializable()
class ServiceId extends ServiceIdEntity {
  @override
  @JsonKey(name: '_id')
  final String? id;
  @override
  final String? name;
  @override
  final int? price;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
  @override
  @JsonKey(name: '__v')
  final int? v;

  const ServiceId({
    this.id,
    this.name,
    this.price,
    this.createdAt,
    this.updatedAt,
    this.v,
  }) : super(
         id: id,
         name: name,
         price: price,
         createdAt: createdAt,
         updatedAt: updatedAt,
         v: v,
       );

  factory ServiceId.fromJson(Map<String, dynamic> json) {
    return _$ServiceIdFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ServiceIdToJson(this);

  ServiceId copyWith({
    String? id,
    String? name,
    int? price,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? v,
  }) {
    return ServiceId(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      v: v ?? this.v,
    );
  }
}
