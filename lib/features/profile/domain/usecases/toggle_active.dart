import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/toggle_active_entity.dart';
import '../repositories/profile_repository.dart';

class ToggleActiveParams {
  final bool isActive;

  const ToggleActiveParams({required this.isActive});
}

class ToggleActive
    extends UseCase<Either<Failure, ToggleActiveEntity>, ToggleActiveParams> {
  final ProfileRepository repository;

  ToggleActive(this.repository);

  @override
  Future<Either<Failure, ToggleActiveEntity>> call(ToggleActiveParams params) {
    return repository.toggleActive(isActive: params.isActive);
  }
}
