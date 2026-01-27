import 'package:dartz/dartz.dart';
import '../entities/verify_user/verify_user_request_entity.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

import '../entities/verify_user/verify_user_response_entity.dart';
import '../repositories/auth_repository.dart';

class VerifyOtp
    extends
        UseCase<
          Either<Failure, VerifyUserResponseEntity>,
          VerifyOtpRequestEntity
        > {
  final AuthRepository authRepository;

  VerifyOtp(this.authRepository);
  @override
  Future<Either<Failure, VerifyUserResponseEntity>> call(
    VerifyOtpRequestEntity params,
  ) async {
    return await authRepository.verifyOtp(params);
  }
}
