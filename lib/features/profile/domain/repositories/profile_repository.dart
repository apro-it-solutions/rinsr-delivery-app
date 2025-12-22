import 'package:dartz/dartz.dart';
import 'package:rinsr_delivery_partner/features/profile/domain/entities/get_agent_entity.dart';

import '../../../../core/error/failures.dart';

abstract class ProfileRepository {
  Future<Either<Failure, GetAgentEntity>> getAgentDetails();
}
