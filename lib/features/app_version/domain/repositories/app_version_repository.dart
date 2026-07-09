import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/app_version_entity.dart';

abstract class AppVersionRepository {
  Future<Either<Failure, AppVersionEntity>> checkAppVersion();
}
