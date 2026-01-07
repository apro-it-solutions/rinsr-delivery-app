import 'package:json_annotation/json_annotation.dart';
import '../../../../home/domain/entities/get_orders_entity.dart';

part 'picked_up.g.dart';

@JsonSerializable()
class PickedUp extends DeliveryUpdateItemEntity {
  @override
  final String? status;
  @override
  @JsonKey(name: 'delivery_id')
  final String? deliveryId;
  @override
  final DateTime? timestamp;
  @override
  @JsonKey(name: '_id')
  final String? id;

  const PickedUp({this.status, this.deliveryId, this.timestamp, this.id})
    : super(
        status: status,
        deliveryId: deliveryId,
        timestamp: timestamp,
        id: id,
      );

  factory PickedUp.fromJson(Map<String, dynamic> json) {
    return _$PickedUpFromJson(json);
  }

  Map<String, dynamic> toJson() => _$PickedUpToJson(this);

  PickedUp copyWith({
    String? status,
    String? deliveryId,
    DateTime? timestamp,
    String? id,
  }) {
    return PickedUp(
      status: status ?? this.status,
      deliveryId: deliveryId ?? this.deliveryId,
      timestamp: timestamp ?? this.timestamp,
      id: id ?? this.id,
    );
  }
}
