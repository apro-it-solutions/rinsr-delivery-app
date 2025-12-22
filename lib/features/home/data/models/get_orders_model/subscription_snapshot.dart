import 'package:json_annotation/json_annotation.dart';

import '../../../domain/entities/get_orders_entity.dart';

part 'subscription_snapshot.g.dart';

@JsonSerializable()
class SubscriptionSnapshot extends SubscriptionSnapshotEntity {
  @override
  @JsonKey(name: 'plan_name')
  final String? planName;
  @override
  @JsonKey(name: 'remaining_bags')
  final int? remainingBags;
  @override
  @JsonKey(name: 'next_renewal_date')
  final DateTime? nextRenewalDate;

  const SubscriptionSnapshot({
    this.planName,
    this.remainingBags,
    this.nextRenewalDate,
  }) : super(
         planName: planName,
         remainingBags: remainingBags,
         nextRenewalDate: nextRenewalDate,
       );

  factory SubscriptionSnapshot.fromJson(Map<String, dynamic> json) {
    return _$SubscriptionSnapshotFromJson(json);
  }

  Map<String, dynamic> toJson() => _$SubscriptionSnapshotToJson(this);

  SubscriptionSnapshot copyWith({
    String? planName,
    int? remainingBags,
    DateTime? nextRenewalDate,
  }) {
    return SubscriptionSnapshot(
      planName: planName ?? this.planName,
      remainingBags: remainingBags ?? this.remainingBags,
      nextRenewalDate: nextRenewalDate ?? this.nextRenewalDate,
    );
  }
}
