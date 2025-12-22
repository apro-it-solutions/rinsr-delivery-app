import 'package:json_annotation/json_annotation.dart';

import '../../../../domain/entities/verify_user/verify_user_request_entity.dart';

part 'verify_otp_request_model.g.dart';

@JsonSerializable()
class VerifyOtpRequestModel extends VerifyOtpRequestEntity {
  const VerifyOtpRequestModel({super.phone, super.otp});

  factory VerifyOtpRequestModel.fromJson(Map<String, dynamic> json) {
    return _$VerifyOtpRequestModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$VerifyOtpRequestModelToJson(this);

  VerifyOtpRequestModel copyWith({String? phone, String? otp}) {
    return VerifyOtpRequestModel(
      phone: phone ?? this.phone,
      otp: otp ?? this.otp,
    );
  }

  factory VerifyOtpRequestModel.fromEntity(VerifyOtpRequestEntity entity) {
    return VerifyOtpRequestModel(phone: entity.phone, otp: entity.otp);
  }
}
