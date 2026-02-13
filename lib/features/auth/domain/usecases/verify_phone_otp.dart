import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class VerifyPhoneOtp {
  final AuthRepository repository;

  VerifyPhoneOtp(this.repository);

  Future<Either<Failure, UserCredential>> call({
    required String verificationId,
    required String smsCode,
  }) async {
    return await repository.verifyPhoneOtp(
      verificationId: verificationId,
      smsCode: smsCode,
    );
  }
}
