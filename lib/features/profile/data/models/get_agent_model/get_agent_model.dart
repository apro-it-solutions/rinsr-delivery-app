import 'package:json_annotation/json_annotation.dart';
import 'package:rinsr_delivery_partner/features/profile/domain/entities/get_agent_entity.dart';

import 'delivery_partner.dart';

part 'get_agent_model.g.dart';

@JsonSerializable()
class GetAgentModel extends GetAgentEntity {
  @override
  final bool? success;
  @override
  final DeliveryPartner? deliveryPartner;

  const GetAgentModel({this.success, this.deliveryPartner})
    : super(deliveryPartner: deliveryPartner, success: success);

  factory GetAgentModel.fromJson(Map<String, dynamic> json) {
    return _$GetAgentModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$GetAgentModelToJson(this);

  GetAgentModel copyWith({bool? success, DeliveryPartner? deliveryPartner}) {
    return GetAgentModel(
      success: success ?? this.success,
      deliveryPartner: deliveryPartner ?? this.deliveryPartner,
    );
  }
}
