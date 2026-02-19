import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/verify_user/verify_user_response_entity.dart';
import '../repositories/auth_repository.dart';

class AuthenticateWithBackend {
  final AuthRepository repository;

  AuthenticateWithBackend(this.repository);

  Future<Either<Failure, VerifyUserResponseEntity>> call({
    required String idToken,
  }) async {
    return await repository.authenticateWithBackend(idToken: idToken);
  }
}
