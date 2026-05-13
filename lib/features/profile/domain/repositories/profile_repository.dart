import 'package:dartz/dartz.dart';
import '../entities/get_agent_entity.dart';
import '../entities/toggle_active_entity.dart';

import '../../../../core/error/failures.dart';

abstract class ProfileRepository {
  Future<Either<Failure, GetAgentEntity>> getAgentDetails();
  Future<Either<Failure, ToggleActiveEntity>> toggleActive({
    required bool isActive,
  });
}
