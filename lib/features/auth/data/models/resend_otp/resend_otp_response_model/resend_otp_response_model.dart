import 'package:json_annotation/json_annotation.dart';

import '../../../../domain/entities/resend_otp/resend_otp_response_entity.dart';

part 'resend_otp_response_model.g.dart';

@JsonSerializable()
class ResendOtpResponseModel extends ResendOtpResponseEntity {
  const ResendOtpResponseModel({super.message});

  factory ResendOtpResponseModel.fromJson(Map<String, dynamic> json) {
    return _$ResendOtpResponseModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ResendOtpResponseModelToJson(this);

  ResendOtpResponseModel copyWith({String? message}) {
    return ResendOtpResponseModel(message: message ?? this.message);
  }
}
