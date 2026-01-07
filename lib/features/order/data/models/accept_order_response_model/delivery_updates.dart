import 'package:json_annotation/json_annotation.dart';
import '../../../domain/entities/accept_order_response_entity.dart';

import 'picked_up.dart';

part 'delivery_updates.g.dart';

@JsonSerializable()
class DeliveryUpdates extends AcceptDeliveryUpdatesEntity {
  @override
  @JsonKey(name: 'picked_up')
  final List<PickedUp>? pickedUp;
  @override
  final List<dynamic>? delivered;
  @override
  @JsonKey(name: 'current_delivery_partner_id')
  final String? currentDeliveryPartnerId;

  const DeliveryUpdates({
    this.pickedUp,
    this.delivered,
    this.currentDeliveryPartnerId,
  }) : super(
         pickedUp: pickedUp,
         delivered: delivered,
         currentDeliveryPartnerId: currentDeliveryPartnerId,
       );

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
