import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/send_otp/send_otp_request_entity.dart';
import '../entities/send_otp/send_otp_response_entity.dart';
import '../repositories/auth_repository.dart';

class SendOtp
    extends
        UseCase<Either<Failure, SendOtpResponseEntity>, SendOtpRequestEntity> {
  final AuthRepository authRepository;

  SendOtp(this.authRepository);
  @override
  Future<Either<Failure, SendOtpResponseEntity>> call(
    SendOtpRequestEntity params,
  ) async {
    return await authRepository.sendOtp(params);
  }
}
