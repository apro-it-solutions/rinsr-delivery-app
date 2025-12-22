import 'package:json_annotation/json_annotation.dart';
import 'package:rinsr_delivery_partner/features/home/domain/entities/get_orders_entity.dart';

part 'pickup_time_slot.g.dart';

@JsonSerializable()
class PickupTimeSlot extends PickupTimeSlotEntity {
  final String? start;
  final String? end;

  const PickupTimeSlot({this.start, this.end})
    : super(startTime: start, endTime: end);

  factory PickupTimeSlot.fromJson(Map<String, dynamic> json) {
    return _$PickupTimeSlotFromJson(json);
  }

  Map<String, dynamic> toJson() => _$PickupTimeSlotToJson(this);

  PickupTimeSlot copyWith({String? start, String? end}) {
    return PickupTimeSlot(start: start ?? this.start, end: end ?? this.end);
  }
}
