import 'package:dio/dio.dart';
import '../../../../core/constants/api_urls.dart';

import '../models/firebase_auth/firebase_auth_request_model.dart';
import '../models/firebase_auth/firebase_auth_response_model.dart';

abstract class AuthRemoteDataSource {
  Future<FirebaseAuthResponseModel> firebaseAuth(
    FirebaseAuthRequestModel request,
  );
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl(this.dio);
  @override
  Future<FirebaseAuthResponseModel> firebaseAuth(
    FirebaseAuthRequestModel request,
  ) async {
    final Response response = await dio.post(
      ApiUrls.firebaseAuth,
      data: request.toJson(),
    );
    return FirebaseAuthResponseModel.fromJson(response.data);
  }
}
