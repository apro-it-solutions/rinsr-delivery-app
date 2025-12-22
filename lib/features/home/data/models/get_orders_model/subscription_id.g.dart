// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_id.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubscriptionId _$SubscriptionIdFromJson(Map<String, dynamic> json) =>
    SubscriptionId(
      id: json['_id'] as String?,
      userId: json['user_id'] as String?,
      planId: json['plan_id'] as String?,
      startDate: json['start_date'] == null
          ? null
          : DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] == null
          ? null
          : DateTime.parse(json['end_date'] as String),
      status: json['status'] as String?,
      usedWeightKg: (json['used_weight_kg'] as num?)?.toInt(),
      usedPickups: (json['used_pickups'] as num?)?.toInt(),
      autoRenew: json['auto_renew'] as bool?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      v: (json['__v'] as num?)?.toInt(),
    );

Map<String, dynamic> _$SubscriptionIdToJson(SubscriptionId instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'user_id': instance.userId,
      'plan_id': instance.planId,
      'start_date': instance.startDate?.toIso8601String(),
      'end_date': instance.endDate?.toIso8601String(),
      'status': instance.status,
      'used_weight_kg': instance.usedWeightKg,
      'used_pickups': instance.usedPickups,
      'auto_renew': instance.autoRenew,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      '__v': instance.v,
    };
