import 'package:dio/dio.dart';
import 'package:rinsr_delivery_partner/core/constants/api_urls.dart';

import '../models/get_agent_model/get_agent_model.dart';

abstract class ProfileRemoteDataSource {
  Future<GetAgentModel> getAgentDetails();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio dio;

  ProfileRemoteDataSourceImpl(this.dio);
  @override
  Future<GetAgentModel> getAgentDetails() async {
    final Response response = await dio.get(ApiUrls.getAgentDetails);
    return GetAgentModel.fromJson(response.data);
  }
}
