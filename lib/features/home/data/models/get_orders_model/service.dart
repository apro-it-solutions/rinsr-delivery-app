import 'package:json_annotation/json_annotation.dart';

import '../../../domain/entities/get_orders_entity.dart';

part 'service.g.dart';

@JsonSerializable()
class Service extends ServiceEntity {
  @override
  final String? serviceId;
  @override
  final String? name;
  @override
  @JsonKey(name: '_id')
  final String? id;

  const Service({this.serviceId, this.name, this.id})
    : super(serviceId: serviceId, name: name, id: id);

  factory Service.fromJson(Map<String, dynamic> json) {
    return _$ServiceFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ServiceToJson(this);

  Service copyWith({String? serviceId, String? name, String? id}) {
    return Service(
      serviceId: serviceId ?? this.serviceId,
      name: name ?? this.name,
      id: id ?? this.id,
    );
  }
}
