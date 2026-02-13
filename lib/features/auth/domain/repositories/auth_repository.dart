import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/firebase_auth/firebase_auth_response_model.dart';

abstract class AuthRepository {
  Future<Either<Failure, void>> loginWithPhone({
    required String phoneNumber,
    required Function(String, int?) codeSent,
    required Function(String) verificationFailed,
  });

  Future<Either<Failure, UserCredential>> verifyPhoneOtp({
    required String verificationId,
    required String smsCode,
  });

  Future<Either<Failure, FirebaseAuthResponseModel>> authenticateWithBackend({
    required String idToken,
    String? fcmToken,
  });
}
