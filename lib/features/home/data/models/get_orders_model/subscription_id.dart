import 'package:json_annotation/json_annotation.dart';

import '../../../domain/entities/get_orders_entity.dart';

part 'subscription_id.g.dart';

@JsonSerializable()
class SubscriptionId extends SubscriptionIdEntity {
  @override
  @JsonKey(name: '_id')
  final String? id;
  @override
  @JsonKey(name: 'user_id')
  final String? userId;
  @override
  @JsonKey(name: 'plan_id')
  final String? planId;
  @override
  @JsonKey(name: 'start_date')
  final DateTime? startDate;
  @override
  @JsonKey(name: 'end_date')
  final DateTime? endDate;
  @override
  final String? status;
  @override
  @JsonKey(name: 'used_weight_kg')
  final int? usedWeightKg;
  @override
  @JsonKey(name: 'used_pickups')
  final int? usedPickups;
  @override
  @JsonKey(name: 'auto_renew')
  final bool? autoRenew;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
  @override
  @JsonKey(name: '__v')
  final int? v;

  const SubscriptionId({
    this.id,
    this.userId,
    this.planId,
    this.startDate,
    this.endDate,
    this.status,
    this.usedWeightKg,
    this.usedPickups,
    this.autoRenew,
    this.createdAt,
    this.updatedAt,
    this.v,
  }) : super(
         id: id,
         userId: userId,
         planId: planId,
         startDate: startDate,
         endDate: endDate,
         status: status,
         usedWeightKg: usedWeightKg,
         usedPickups: usedPickups,
         autoRenew: autoRenew,
         createdAt: createdAt,
         updatedAt: updatedAt,
         v: v,
       );

  factory SubscriptionId.fromJson(Map<String, dynamic> json) {
    return _$SubscriptionIdFromJson(json);
  }

  Map<String, dynamic> toJson() => _$SubscriptionIdToJson(this);

  SubscriptionId copyWith({
    String? id,
    String? userId,
    String? planId,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    int? usedWeightKg,
    int? usedPickups,
    bool? autoRenew,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? v,
  }) {
    return SubscriptionId(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      planId: planId ?? this.planId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      usedWeightKg: usedWeightKg ?? this.usedWeightKg,
      usedPickups: usedPickups ?? this.usedPickups,
      autoRenew: autoRenew ?? this.autoRenew,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      v: v ?? this.v,
    );
  }
}
