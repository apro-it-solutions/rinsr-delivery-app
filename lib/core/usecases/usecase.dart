abstract class UseCase<T, Params> {
  Future<T> call(Params params);
}

/// For usecases that don’t need parameters
class NoParams {
  const NoParams();
}
