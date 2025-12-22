import 'package:json_annotation/json_annotation.dart';

import '../../../../domain/entities/send_otp/send_otp_response_entity.dart';

part 'send_otp_response_model.g.dart';

@JsonSerializable()
class SendOtpResponseModel extends SendOtpResponseEntity {
  const SendOtpResponseModel({super.message});

  factory SendOtpResponseModel.fromJson(Map<String, dynamic> json) {
    return _$SendOtpResponseModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$SendOtpResponseModelToJson(this);

  SendOtpResponseModel copyWith({String? message}) {
    return SendOtpResponseModel(message: message ?? this.message);
  }
}
