import 'package:dartz/dartz.dart';
import '../../../../core/network/api_handler.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/error/failures.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/verify_user/verify_user_response_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../data_sources/auth_remote_datasource.dart';
import '../models/firebase_auth/firebase_auth_request_model.dart';

class AuthRepositoriesImpl implements AuthRepository {
  final ApiHandler apiHandler;
  final NetworkInfo networkInfo;
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoriesImpl(
    this.apiHandler,
    this.networkInfo,
    this.remoteDataSource,
  );
  @override
  Future<Either<Failure, void>> loginWithPhone({
    required String phoneNumber,
    required Function(String, int?) codeSent,
    required Function(String) verificationFailed,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+91$phoneNumber',
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-resolution (Android only) - we can handle this if needed,
          // but usually we wait for the user to input the code or the codeSent callback.
        },
        verificationFailed: (FirebaseAuthException e) {
          verificationFailed(e.message ?? 'Verification failed');
        },
        codeSent: codeSent,
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Firebase Auth Error'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserCredential>> verifyPhoneOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      return Right(userCredential);
    } on FirebaseAuthException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Verification failed'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, VerifyUserResponseEntity>> authenticateWithBackend({
    required String idToken,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    return apiHandler.execute(() {
      final request = FirebaseAuthRequestModel(idToken: idToken);
      return remoteDataSource.firebaseAuth(request);
    });
  }
}
