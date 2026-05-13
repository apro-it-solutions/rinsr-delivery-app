import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/ratings_entity.dart';
import '../repositories/profile_repository.dart';

class GetRatingsParams {
  final String partnerId;

  const GetRatingsParams({required this.partnerId});
}

class GetRatings
    extends UseCase<Either<Failure, RatingsEntity>, GetRatingsParams> {
  final ProfileRepository repository;

  GetRatings(this.repository);

  @override
  Future<Either<Failure, RatingsEntity>> call(GetRatingsParams params) {
    return repository.getRatings(partnerId: params.partnerId);
  }
}
