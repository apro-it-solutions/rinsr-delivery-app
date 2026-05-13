import '../../domain/entities/update_profile_image_entity.dart';

class UpdateProfileImageModel extends UpdateProfileImageEntity {
  const UpdateProfileImageModel({
    super.success,
    super.message,
    super.photo,
    super.photoUrl,
  });

  factory UpdateProfileImageModel.fromJson(Map<String, dynamic> json) {
    return UpdateProfileImageModel(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      photo: json['photo'] as String?,
      photoUrl: json['photo_url'] as String?,
    );
  }
}
