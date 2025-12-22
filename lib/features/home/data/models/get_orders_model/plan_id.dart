import 'package:json_annotation/json_annotation.dart';

import '../../../domain/entities/get_orders_entity.dart';
import 'service.dart';

part 'plan_id.g.dart';

@JsonSerializable()
class PlanId extends PlanIdEntity {
  @override
  @JsonKey(name: '_id')
  final String? id;
  @override
  final String? name;
  @override
  final String? description;
  @override
  final int? price;
  @override
  final String? currency;
  @override
  @JsonKey(name: 'validity_days')
  final int? validityDays;
  @override
  @JsonKey(name: 'weight_limit_kg')
  final int? weightLimitKg;
  @override
  @JsonKey(name: 'pickups_per_month')
  final int? pickupsPerMonth;
  @override
  final List<String>? features;
  @override
  final List<Service>? services;
  @override
  @JsonKey(name: 'extra_kg_rate')
  final int? extraKgRate;
  @override
  @JsonKey(name: 'rollover_limit_months')
  final int? rolloverLimitMonths;
  @override
  @JsonKey(name: 'is_active')
  final bool? isActive;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
  @override
  @JsonKey(name: '__v')
  final int? v;

  const PlanId({
    this.id,
    this.name,
    this.description,
    this.price,
    this.currency,
    this.validityDays,
    this.weightLimitKg,
    this.pickupsPerMonth,
    this.features,
    this.services,
    this.extraKgRate,
    this.rolloverLimitMonths,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.v,
  }) : super(
         id: id,
         name: name,
         description: description,
         price: price,
         currency: currency,
         validityDays: validityDays,
         weightLimitKg: weightLimitKg,
         pickupsPerMonth: pickupsPerMonth,
         features: features,
         services: services,
         extraKgRate: extraKgRate,
         rolloverLimitMonths: rolloverLimitMonths,
         isActive: isActive,
         createdAt: createdAt,
         updatedAt: updatedAt,
         v: v,
       );

  factory PlanId.fromJson(Map<String, dynamic> json) {
    return _$PlanIdFromJson(json);
  }

  Map<String, dynamic> toJson() => _$PlanIdToJson(this);

  PlanId copyWith({
    String? id,
    String? name,
    String? description,
    int? price,
    String? currency,
    int? validityDays,
    int? weightLimitKg,
    int? pickupsPerMonth,
    List<String>? features,
    List<Service>? services,
    int? extraKgRate,
    int? rolloverLimitMonths,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? v,
  }) {
    return PlanId(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      validityDays: validityDays ?? this.validityDays,
      weightLimitKg: weightLimitKg ?? this.weightLimitKg,
      pickupsPerMonth: pickupsPerMonth ?? this.pickupsPerMonth,
      features: features ?? this.features,
      services: services ?? this.services,
      extraKgRate: extraKgRate ?? this.extraKgRate,
      rolloverLimitMonths: rolloverLimitMonths ?? this.rolloverLimitMonths,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      v: v ?? this.v,
    );
  }
}
