import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/app_version_entity.dart';
import '../repositories/app_version_repository.dart';

class CheckAppVersion
    extends UseCase<Either<Failure, AppVersionEntity>, NoParams> {
  final AppVersionRepository repository;

  CheckAppVersion(this.repository);

  @override
  Future<Either<Failure, AppVersionEntity>> call(NoParams params) {
    return repository.checkAppVersion();
  }
}
