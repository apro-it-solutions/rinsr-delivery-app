import 'package:json_annotation/json_annotation.dart';

import '../../../domain/entities/get_orders_entity.dart';

part 'delivery_updates.g.dart';

@JsonSerializable()
class DeliveryUpdates extends DeliveryUpdatesEntity {
  @override
  @JsonKey(name: 'current_delivery_partner_id')
  final String? currentDeliveryPartnerId;
  @override
  @JsonKey(name: 'delivered')
  final List<DeliveryUpdateItem>? delivered;
  @override
  @JsonKey(name: 'picked_up')
  final List<DeliveryUpdateItem>? pickedUp;

  const DeliveryUpdates({
    this.currentDeliveryPartnerId,
    this.delivered,
    this.pickedUp,
  }) : super(
         currentDeliveryPartnerId: currentDeliveryPartnerId,
         delivered: delivered,
         pickedUp: pickedUp,
       );

  factory DeliveryUpdates.fromJson(Map<String, dynamic> json) =>
      _$DeliveryUpdatesFromJson(json);

  Map<String, dynamic> toJson() => _$DeliveryUpdatesToJson(this);
}

@JsonSerializable()
class DeliveryUpdateItem extends DeliveryUpdateItemEntity {
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

  const DeliveryUpdateItem({
    this.status,
    this.deliveryId,
    this.timestamp,
    this.id,
  }) : super(
         status: status,
         deliveryId: deliveryId,
         timestamp: timestamp,
         id: id,
       );

  factory DeliveryUpdateItem.fromJson(Map<String, dynamic> json) =>
      _$DeliveryUpdateItemFromJson(json);

  Map<String, dynamic> toJson() => _$DeliveryUpdateItemToJson(this);
}
