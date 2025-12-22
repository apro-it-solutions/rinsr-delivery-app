import 'package:dio/dio.dart';
import 'package:rinsr_delivery_partner/core/constants/api_urls.dart';

import '../models/resend_otp/resend_otp_request_model/resend_otp_request_model.dart';
import '../models/resend_otp/resend_otp_response_model/resend_otp_response_model.dart';
import '../models/send_otp/send_otp_request_model/send_otp_request_model.dart';
import '../models/send_otp/send_otp_response_model/send_otp_response_model.dart';
import '../models/verify_otp/verify_otp_request_model/verify_otp_request_model.dart';
import '../models/verify_otp/verify_otp_response_model/verify_otp_response_model.dart';

abstract class AuthRemoteDataSource {
  Future<SendOtpResponseModel> sendOtp(SendOtpRequestModel request);
  Future<VerifyOtpResponseModel> verifyOtp(VerifyOtpRequestModel request);
  Future<ResendOtpResponseModel> resendOtp(ResendOtpRequestModel request);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl(this.dio);
  @override
  Future<ResendOtpResponseModel> resendOtp(
    ResendOtpRequestModel request,
  ) async {
    final Response response = await dio.post(
      ApiUrls.resendOtp,
      data: request.toJson(),
    );
    return ResendOtpResponseModel.fromJson(response.data);
  }

  @override
  Future<SendOtpResponseModel> sendOtp(SendOtpRequestModel request) async {
    final Response response = await dio.post(
      ApiUrls.sendOtp,
      data: request.toJson(),
    );
    return SendOtpResponseModel.fromJson(response.data);
  }

  @override
  Future<VerifyOtpResponseModel> verifyOtp(
    VerifyOtpRequestModel request,
  ) async {
    final Response response = await dio.post(
      ApiUrls.verifyOtp,
      data: request.toJson(),
    );
    return VerifyOtpResponseModel.fromJson(response.data);
  }
}
