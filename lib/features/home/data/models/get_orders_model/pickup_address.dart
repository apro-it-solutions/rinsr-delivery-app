import 'package:json_annotation/json_annotation.dart';

import '../../../domain/entities/get_orders_entity.dart';

part 'pickup_address.g.dart';

@JsonSerializable()
class PickupAddress extends PickupAddressEntity {
  @override
  final String? label;
  @override
  @JsonKey(name: 'address_line')
  final String? addressLine;
  @override
  final String? coordinates;

  const PickupAddress({this.label, this.addressLine, this.coordinates})
    : super(label: label, addressLine: addressLine, coordinates: coordinates);

  factory PickupAddress.fromJson(Map<String, dynamic> json) {
    return _$PickupAddressFromJson(json);
  }

  Map<String, dynamic> toJson() => _$PickupAddressToJson(this);

  PickupAddress copyWith({
    String? label,
    String? addressLine,
    String? coordinates,
  }) {
    return PickupAddress(
      label: label ?? this.label,
      addressLine: addressLine ?? this.addressLine,
      coordinates: coordinates ?? this.coordinates,
    );
  }
}
