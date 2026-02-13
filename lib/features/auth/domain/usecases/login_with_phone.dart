import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class LoginWithPhone {
  final AuthRepository repository;

  LoginWithPhone(this.repository);

  Future<Either<Failure, void>> call({
    required String phoneNumber,
    required Function(String, int?) codeSent,
    required Function(String) verificationFailed,
  }) async {
    return await repository.loginWithPhone(
      phoneNumber: phoneNumber,
      codeSent: codeSent,
      verificationFailed: verificationFailed,
    );
  }
}
