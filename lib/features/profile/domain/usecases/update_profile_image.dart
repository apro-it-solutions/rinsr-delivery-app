import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/update_profile_image_entity.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileImageParams {
  final String filePath;

  const UpdateProfileImageParams({required this.filePath});
}

class UpdateProfileImage
    extends
        UseCase<
          Either<Failure, UpdateProfileImageEntity>,
          UpdateProfileImageParams
        > {
  final ProfileRepository repository;

  UpdateProfileImage(this.repository);

  @override
  Future<Either<Failure, UpdateProfileImageEntity>> call(
    UpdateProfileImageParams params,
  ) {
    return repository.updateProfileImage(filePath: params.filePath);
  }
}
