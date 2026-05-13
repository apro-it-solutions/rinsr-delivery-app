import 'package:dio/dio.dart';
import '../../../../core/constants/api_urls.dart';

import '../models/get_agent_model/get_agent_model.dart';
import '../models/toggle_active_model.dart';

abstract class ProfileRemoteDataSource {
  Future<GetAgentModel> getAgentDetails();
  Future<ToggleActiveModel> toggleActive({required bool isActive});
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio dio;

  ProfileRemoteDataSourceImpl(this.dio);
  @override
  Future<GetAgentModel> getAgentDetails() async {
    final Response response = await dio.get(ApiUrls.getAgentDetails);
    return GetAgentModel.fromJson(response.data);
  }

  @override
  Future<ToggleActiveModel> toggleActive({required bool isActive}) async {
    final Response response = await dio.patch(
      ApiUrls.toggleActive,
      data: {'is_active': isActive},
    );
    return ToggleActiveModel.fromJson(response.data);
  }
}
