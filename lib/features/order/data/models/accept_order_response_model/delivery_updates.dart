import 'package:json_annotation/json_annotation.dart';

import 'picked_up.dart';

part 'delivery_updates.g.dart';

@JsonSerializable()
class DeliveryUpdates {
  @JsonKey(name: 'picked_up')
  final List<PickedUp>? pickedUp;
  final List<dynamic>? delivered;
  @JsonKey(name: 'current_delivery_partner_id')
  final String? currentDeliveryPartnerId;

  const DeliveryUpdates({
    this.pickedUp,
    this.delivered,
    this.currentDeliveryPartnerId,
  });

  factory DeliveryUpdates.fromJson(Map<String, dynamic> json) {
    return _$DeliveryUpdatesFromJson(json);
  }

  Map<String, dynamic> toJson() => _$DeliveryUpdatesToJson(this);

  DeliveryUpdates copyWith({
    List<PickedUp>? pickedUp,
    List<dynamic>? delivered,
    String? currentDeliveryPartnerId,
  }) {
    return DeliveryUpdates(
      pickedUp: pickedUp ?? this.pickedUp,
      delivered: delivered ?? this.delivered,
      currentDeliveryPartnerId:
          currentDeliveryPartnerId ?? this.currentDeliveryPartnerId,
    );
  }
}
