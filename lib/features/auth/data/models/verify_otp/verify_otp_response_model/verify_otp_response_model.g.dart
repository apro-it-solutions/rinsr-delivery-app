// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verify_otp_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VerifyOtpResponseModel _$VerifyOtpResponseModelFromJson(
  Map<String, dynamic> json,
) => VerifyOtpResponseModel(
  success: json['success'] as bool?,
  message: json['message'] as String?,
  token: json['token'] as String?,
  deliveryPartner: json['deliveryPartner'] == null
      ? null
      : DeliveryPartner.fromJson(
          json['deliveryPartner'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$VerifyOtpResponseModelToJson(
  VerifyOtpResponseModel instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'token': instance.token,
  'deliveryPartner': instance.deliveryPartner,
};
