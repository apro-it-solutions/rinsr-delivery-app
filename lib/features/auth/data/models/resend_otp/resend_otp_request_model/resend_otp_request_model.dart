import 'package:json_annotation/json_annotation.dart';

import '../../../../domain/entities/resend_otp/resend_otp_request_entity.dart';

part 'resend_otp_request_model.g.dart';

@JsonSerializable()
class ResendOtpRequestModel extends ResendOtpRequestEntity {
  const ResendOtpRequestModel({super.phone});

  factory ResendOtpRequestModel.fromJson(Map<String, dynamic> json) {
    return _$ResendOtpRequestModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ResendOtpRequestModelToJson(this);

  ResendOtpRequestModel copyWith({String? phone}) {
    return ResendOtpRequestModel(phone: phone ?? this.phone);
  }

  factory ResendOtpRequestModel.fromEntity(ResendOtpRequestEntity entity) {
    return ResendOtpRequestModel(phone: entity.phone);
  }
}
