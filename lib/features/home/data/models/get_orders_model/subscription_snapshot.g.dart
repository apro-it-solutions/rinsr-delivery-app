// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_snapshot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubscriptionSnapshot _$SubscriptionSnapshotFromJson(
  Map<String, dynamic> json,
) => SubscriptionSnapshot(
  planName: json['plan_name'] as String?,
  remainingBags: (json['remaining_bags'] as num?)?.toInt(),
  nextRenewalDate: json['next_renewal_date'] == null
      ? null
      : DateTime.parse(json['next_renewal_date'] as String),
);

Map<String, dynamic> _$SubscriptionSnapshotToJson(
  SubscriptionSnapshot instance,
) => <String, dynamic>{
  'plan_name': instance.planName,
  'remaining_bags': instance.remainingBags,
  'next_renewal_date': instance.nextRenewalDate?.toIso8601String(),
};
