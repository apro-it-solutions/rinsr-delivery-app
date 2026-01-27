import 'package:dartz/dartz.dart';
import '../entities/verify_user/verify_user_response_entity.dart';

import '../../../../core/error/failures.dart';
import '../entities/resend_otp/resend_otp_request_entity.dart';
import '../entities/resend_otp/resend_otp_response_entity.dart';
import '../entities/send_otp/send_otp_request_entity.dart';
import '../entities/send_otp/send_otp_response_entity.dart';
import '../entities/verify_user/verify_user_request_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, ResendOtpResponseEntity>> resendOtp(
    ResendOtpRequestEntity request,
  );
  Future<Either<Failure, SendOtpResponseEntity>> sendOtp(
    SendOtpRequestEntity request,
  );
  Future<Either<Failure, VerifyUserResponseEntity>> verifyOtp(
    VerifyOtpRequestEntity request,
  );
}
