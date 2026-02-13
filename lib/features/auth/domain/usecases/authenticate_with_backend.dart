import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/firebase_auth/firebase_auth_response_model.dart';
import '../repositories/auth_repository.dart';

class AuthenticateWithBackend {
  final AuthRepository repository;

  AuthenticateWithBackend(this.repository);

  Future<Either<Failure, FirebaseAuthResponseModel>> call({
    required String idToken,
    String? fcmToken,
  }) async {
    return await repository.authenticateWithBackend(
      idToken: idToken,
      fcmToken: fcmToken,
    );
  }
}
