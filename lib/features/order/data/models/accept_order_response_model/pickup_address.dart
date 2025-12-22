import 'package:json_annotation/json_annotation.dart';

part 'pickup_address.g.dart';

@JsonSerializable()
class PickupAddress {
  final String? label;
  @JsonKey(name: 'address_line')
  final String? addressLine;

  const PickupAddress({this.label, this.addressLine});

  factory PickupAddress.fromJson(Map<String, dynamic> json) {
    return _$PickupAddressFromJson(json);
  }

  Map<String, dynamic> toJson() => _$PickupAddressToJson(this);

  PickupAddress copyWith({String? label, String? addressLine}) {
    return PickupAddress(
      label: label ?? this.label,
      addressLine: addressLine ?? this.addressLine,
    );
  }
}
