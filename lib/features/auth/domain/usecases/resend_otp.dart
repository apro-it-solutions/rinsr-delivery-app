import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/resend_otp/resend_otp_request_entity.dart';
import '../entities/resend_otp/resend_otp_response_entity.dart';
import '../repositories/auth_repository.dart';

class ResendOtp
    extends
        UseCase<
          Either<Failure, ResendOtpResponseEntity>,
          ResendOtpRequestEntity
        > {
  final AuthRepository authRepository;

  ResendOtp(this.authRepository);
  @override
  Future<Either<Failure, ResendOtpResponseEntity>> call(
    ResendOtpRequestEntity params,
  ) async {
    return await authRepository.resendOtp(params);
  }
}
