// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan_id.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlanId _$PlanIdFromJson(Map<String, dynamic> json) => PlanId(
  id: json['_id'] as String?,
  name: json['name'] as String?,
  description: json['description'] as String?,
  price: (json['price'] as num?)?.toInt(),
  currency: json['currency'] as String?,
  validityDays: (json['validity_days'] as num?)?.toInt(),
  weightLimitKg: (json['weight_limit_kg'] as num?)?.toInt(),
  pickupsPerMonth: (json['pickups_per_month'] as num?)?.toInt(),
  features: (json['features'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  services: (json['services'] as List<dynamic>?)
      ?.map((e) => Service.fromJson(e as Map<String, dynamic>))
      .toList(),
  extraKgRate: (json['extra_kg_rate'] as num?)?.toInt(),
  rolloverLimitMonths: (json['rollover_limit_months'] as num?)?.toInt(),
  isActive: json['is_active'] as bool?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  v: (json['__v'] as num?)?.toInt(),
);

Map<String, dynamic> _$PlanIdToJson(PlanId instance) => <String, dynamic>{
  '_id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'price': instance.price,
  'currency': instance.currency,
  'validity_days': instance.validityDays,
  'weight_limit_kg': instance.weightLimitKg,
  'pickups_per_month': instance.pickupsPerMonth,
  'features': instance.features,
  'services': instance.services,
  'extra_kg_rate': instance.extraKgRate,
  'rollover_limit_months': instance.rolloverLimitMonths,
  'is_active': instance.isActive,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  '__v': instance.v,
};
