// core/network/api_handler.dart
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../error/exceptions.dart';
import '../error/failures.dart';

typedef AsyncCallback<T> = Future<T> Function();

class ApiHandler {
  /// Executes an API call and converts exceptions to Failures
  Future<Either<Failure, T>> execute<T>(AsyncCallback<T> call) async {
    try {
      final result = await call();
      return Right(result);
    } on DioException catch (e) {
      final message = _extractApiMessage(e);
      return Left(ServerFailure(message: message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  String _extractApiMessage(DioException e) {
    try {
      if (e.response != null && e.response?.data != null) {
        final data = e.response?.data;
        if (data is Map<String, dynamic> && data.containsKey('message')) {
          return data['message'] ?? 'Server error occurred';
        }
      }
      return e.message ?? 'Something went wrong';
    } catch (_) {
      return 'Unexpected error occurred';
    }
  }
}
