import 'package:json_annotation/json_annotation.dart';

part 'picked_up.g.dart';

@JsonSerializable()
class PickedUp {
  final String? status;
  @JsonKey(name: 'delivery_id')
  final String? deliveryId;
  final DateTime? timestamp;
  @JsonKey(name: '_id')
  final String? id;

  const PickedUp({this.status, this.deliveryId, this.timestamp, this.id});

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
