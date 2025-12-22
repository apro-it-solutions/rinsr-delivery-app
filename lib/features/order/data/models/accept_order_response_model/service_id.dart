import 'package:json_annotation/json_annotation.dart';

part 'service_id.g.dart';

@JsonSerializable()
class ServiceId {
  @JsonKey(name: '_id')
  final String? id;
  final String? name;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  @JsonKey(name: '__v')
  final int? v;
  final int? price;

  const ServiceId({
    this.id,
    this.name,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.price,
  });

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
