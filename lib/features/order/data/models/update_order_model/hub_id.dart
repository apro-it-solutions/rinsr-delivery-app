import 'package:json_annotation/json_annotation.dart';

import '../../../../home/domain/entities/get_orders_entity.dart';

part 'hub_id.g.dart';

@JsonSerializable()
class HubId extends HubIdEntity {
  @JsonKey(name: '_id')
  final String? id;
  @override
  final String? name;
  @override
  final String? location;
  @override
  @JsonKey(name: 'location_coordinates')
  final String? locationCoordinates;
  @override
  @JsonKey(name: 'primary_contact')
  final String? primaryContact;
  @override
  @JsonKey(name: 'secondary_contact')
  final String? secondaryContact;
  @override
  @JsonKey(name: 'vendor_ids')
  final List<String>? vendorIds;
  @override
  @JsonKey(name: 'delivery_partner_ids')
  final List<String>? deliveryPartnerIds;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
  @JsonKey(name: '__v')
  final int? v;

  const HubId({
    this.id,
    this.name,
    this.location,
    this.locationCoordinates,
    this.primaryContact,
    this.secondaryContact,
    this.vendorIds,
    this.deliveryPartnerIds,
    this.createdAt,
    this.updatedAt,
    this.v,
  }) : super(
         hubId: id,
         name: name,
         location: location,
         locationCoordinates: locationCoordinates,
         primaryContact: primaryContact,
         secondaryContact: secondaryContact,
         vendorIds: vendorIds,
         deliveryPartnerIds: deliveryPartnerIds,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  factory HubId.fromJson(Map<String, dynamic> json) => _$HubIdFromJson(json);

  Map<String, dynamic> toJson() => _$HubIdToJson(this);

  HubId copyWith({
    String? id,
    String? name,
    String? location,
    String? locationCoordinates,
    String? primaryContact,
    String? secondaryContact,
    List<String>? vendorIds,
    List<String>? deliveryPartnerIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? v,
  }) {
    return HubId(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      locationCoordinates: locationCoordinates ?? this.locationCoordinates,
      primaryContact: primaryContact ?? this.primaryContact,
      secondaryContact: secondaryContact ?? this.secondaryContact,
      vendorIds: vendorIds ?? this.vendorIds,
      deliveryPartnerIds: deliveryPartnerIds ?? this.deliveryPartnerIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      v: v ?? this.v,
    );
  }
}
