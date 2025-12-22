import 'package:equatable/equatable.dart';
import 'package:rinsr_delivery_partner/features/auth/domain/entities/verify_user/verify_user_response_entity.dart';

class GetAgentEntity extends Equatable {
  final bool? success;
  final DeliveryPartnerEntity? deliveryPartner;

  const GetAgentEntity({required this.success, required this.deliveryPartner});

  @override
  List<Object?> get props => [success, deliveryPartner];
}
