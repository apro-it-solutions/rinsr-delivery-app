import 'package:dartz/dartz.dart';
import 'package:rinsr_delivery_partner/core/usecases/usecase.dart';

import '../../../../core/error/failures.dart';
import '../entities/get_agent_entity.dart';
import '../repositories/profile_repository.dart';

class GetAgentDetails
    extends UseCase<Either<Failure, GetAgentEntity>, NoParams> {
  final ProfileRepository repository;

  GetAgentDetails(this.repository);

  @override
  Future<Either<Failure, GetAgentEntity>> call(NoParams params) {
    return repository.getAgentDetails();
  }
}
