import 'package:json_annotation/json_annotation.dart';

import '../../../../domain/entities/send_otp/send_otp_request_entity.dart';

part 'send_otp_request_model.g.dart';

@JsonSerializable()
class SendOtpRequestModel extends SendOtpRequestEntity {
  const SendOtpRequestModel({super.phone});

  factory SendOtpRequestModel.fromJson(Map<String, dynamic> json) {
    return _$SendOtpRequestModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$SendOtpRequestModelToJson(this);

  SendOtpRequestModel copyWith({String? phone}) {
    return SendOtpRequestModel(phone: phone ?? this.phone);
  }

  factory SendOtpRequestModel.fromEntity(SendOtpRequestEntity entity) {
    return SendOtpRequestModel(phone: entity.phone);
  }
}
