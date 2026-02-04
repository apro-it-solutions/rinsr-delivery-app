import 'package:dio/dio.dart';
import 'package:rinsr_delivery_partner/features/auth/presentation/auth_router.dart';
import '../routing/router.dart';

import '../constants/constants.dart';
import '../services/shared_preferences_service.dart';

class DioConfig {
  static Dio createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://rinsrapi.aproitsolutions.in/api/',
        connectTimeout: const Duration(minutes: 1),
        receiveTimeout: const Duration(minutes: 1),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = SharedPreferencesService.getString(AppConstants.kToken);

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(options);
        },
        onError: (DioException error, ErrorInterceptorHandler handler) async {
          if (error.response?.statusCode == 401) {
            // Token expired or invalid
            await SharedPreferencesService.clear();
            await AppRouter.navigatorKey.currentState?.pushNamedAndRemoveUntil(
              AuthRouter.login,
              (route) => false,
            );
          }
          return handler.next(error);
        },
      ),
    );
    // Optional: add interceptors for logging, auth, etc.
    dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));

    return dio;
  }
}
