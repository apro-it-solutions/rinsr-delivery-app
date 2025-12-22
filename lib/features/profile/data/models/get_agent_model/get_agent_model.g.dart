// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_agent_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetAgentModel _$GetAgentModelFromJson(Map<String, dynamic> json) =>
    GetAgentModel(
      success: json['success'] as bool?,
      deliveryPartner: json['deliveryPartner'] == null
          ? null
          : DeliveryPartner.fromJson(
              json['deliveryPartner'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$GetAgentModelToJson(GetAgentModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'deliveryPartner': instance.deliveryPartner,
    };
