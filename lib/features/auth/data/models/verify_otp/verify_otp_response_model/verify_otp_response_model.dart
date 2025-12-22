import 'package:json_annotation/json_annotation.dart';

import '../../../../domain/entities/verify_user/verify_user_response_entity.dart';
import 'delivery_partner.dart';

part 'verify_otp_response_model.g.dart';

@JsonSerializable()
class VerifyOtpResponseModel extends VerifyUserResponseEntity {
  @override
  final bool? success;
  @override
  final String? message;
  @override
  final String? token;
  @override
  final DeliveryPartner? deliveryPartner;

  const VerifyOtpResponseModel({
    this.success,
    this.message,
    this.token,
    this.deliveryPartner,
  }) : super(
         success: success,
         message: message,
         token: token,
         deliveryPartner: deliveryPartner,
       );

  factory VerifyOtpResponseModel.fromJson(Map<String, dynamic> json) {
    return _$VerifyOtpResponseModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$VerifyOtpResponseModelToJson(this);

  VerifyOtpResponseModel copyWith({
    bool? success,
    String? message,
    String? token,
    DeliveryPartner? deliveryPartner,
  }) {
    return VerifyOtpResponseModel(
      success: success ?? this.success,
      message: message ?? this.message,
      token: token ?? this.token,
      deliveryPartner: deliveryPartner ?? this.deliveryPartner,
    );
  }
}
