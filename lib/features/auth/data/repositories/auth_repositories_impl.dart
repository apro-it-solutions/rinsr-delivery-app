import 'package:dartz/dartz.dart';
import 'package:rinsr_delivery_partner/core/network/api_handler.dart';
import 'package:rinsr_delivery_partner/core/network/network_info.dart';
import 'package:rinsr_delivery_partner/features/auth/data/models/verify_otp/verify_otp_request_model/verify_otp_request_model.dart';
import 'package:rinsr_delivery_partner/features/auth/domain/entities/resend_otp/resend_otp_request_entity.dart';

import 'package:rinsr_delivery_partner/features/auth/domain/entities/resend_otp/resend_otp_response_entity.dart';

import 'package:rinsr_delivery_partner/features/auth/domain/entities/send_otp/send_otp_request_entity.dart';

import 'package:rinsr_delivery_partner/features/auth/domain/entities/send_otp/send_otp_response_entity.dart';

import 'package:rinsr_delivery_partner/features/auth/domain/entities/verify_user/verify_user_request_entity.dart';

import 'package:rinsr_delivery_partner/features/auth/domain/entities/verify_user/verify_user_response_entity.dart';

import '../../../../core/error/failures.dart';
import '../../domain/repositories/auth_repository.dart';
import '../data_sources/auth_remote_datasource.dart';
import '../models/resend_otp/resend_otp_request_model/resend_otp_request_model.dart';
import '../models/send_otp/send_otp_request_model/send_otp_request_model.dart';

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
  Future<Either<Failure, ResendOtpResponseEntity>> resendOtp(
    ResendOtpRequestEntity request,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    return apiHandler.execute(() {
      final model = ResendOtpRequestModel.fromEntity(request);
      return remoteDataSource.resendOtp(model);
    });
  }

  @override
  Future<Either<Failure, SendOtpResponseEntity>> sendOtp(
    SendOtpRequestEntity request,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    return apiHandler.execute(() {
      final model = SendOtpRequestModel.fromEntity(request);
      return remoteDataSource.sendOtp(model);
    });
  }

  @override
  Future<Either<Failure, VerifyUserResponseEntity>> verifyOtp(
    VerifyOtpRequestEntity request,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    return apiHandler.execute(() {
      final model = VerifyOtpRequestModel.fromEntity(request);
      return remoteDataSource.verifyOtp(model);
    });
  }
}
