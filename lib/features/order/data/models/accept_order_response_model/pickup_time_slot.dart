import 'package:json_annotation/json_annotation.dart';

part 'pickup_time_slot.g.dart';

@JsonSerializable()
class PickupTimeSlot {
  final String? start;
  final String? end;

  const PickupTimeSlot({this.start, this.end});

  factory PickupTimeSlot.fromJson(Map<String, dynamic> json) {
    return _$PickupTimeSlotFromJson(json);
  }

  Map<String, dynamic> toJson() => _$PickupTimeSlotToJson(this);

  PickupTimeSlot copyWith({String? start, String? end}) {
    return PickupTimeSlot(start: start ?? this.start, end: end ?? this.end);
  }
}
