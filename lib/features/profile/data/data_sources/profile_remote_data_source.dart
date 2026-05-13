import 'package:dio/dio.dart';
import '../../../../core/constants/api_urls.dart';

import '../models/get_agent_model/get_agent_model.dart';
import '../models/ratings_model.dart';
import '../models/toggle_active_model.dart';
import '../models/update_profile_image_model.dart';

abstract class ProfileRemoteDataSource {
  Future<GetAgentModel> getAgentDetails();
  Future<ToggleActiveModel> toggleActive({required bool isActive});
  Future<RatingsModel> getRatings({required String partnerId});
  Future<UpdateProfileImageModel> updateProfileImage({
    required String filePath,
  });
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

  @override
  Future<RatingsModel> getRatings({required String partnerId}) async {
    final Response response = await dio.get(ApiUrls.getRatings(partnerId));
    return RatingsModel.fromJson(response.data);
  }

  @override
  Future<UpdateProfileImageModel> updateProfileImage({
    required String filePath,
  }) async {
    final formData = FormData.fromMap({
      'photo': await MultipartFile.fromFile(filePath),
    });
    final Response response = await dio.post(
      ApiUrls.updateProfileImage,
      data: formData,
    );
    return UpdateProfileImageModel.fromJson(response.data);
  }
}
