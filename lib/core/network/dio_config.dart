import 'package:dio/dio.dart';
import 'package:rinsr_delivery_partner/features/auth/presentation/auth_router.dart';
import '../routing/router.dart';

import '../constants/constants.dart';
import '../services/shared_preferences_service.dart';
import '../utils/app_alerts.dart';

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
          // 1. Handle Logout Scenarios (401/403)
          if (error.response?.statusCode == 401 ||
              error.response?.statusCode == 403) {
            // Only clear auth related data if possible, otherwise clear() is fine but aggressive
            await SharedPreferencesService.clear();

            await AppRouter.navigatorKey.currentState?.pushNamedAndRemoveUntil(
              AuthRouter.login,
              (route) => false,
            );

            AppAlerts.showErrorSnackBar(
              context: AppRouter.navigatorKey.currentContext!,
              message: 'Session expired. Please login again.',
            );
          }
          // 2. Handle 500+ Server Errors
          else if (error.response?.statusCode != null &&
              error.response!.statusCode! >= 500) {
            AppAlerts.showErrorSnackBar(
              context: AppRouter.navigatorKey.currentContext!,
              message: 'Server error. Please try again later.',
            );
          }
          // 3. Handle Network/Connection Errors
          else if (error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.receiveTimeout ||
              error.type == DioExceptionType.connectionError) {
            AppAlerts.showErrorSnackBar(
              context: AppRouter.navigatorKey.currentContext!,
              message: 'Please check your internet connection.',
            );
          }

          // 4. Pass the error along to the caller (so Try/Catch blocks in your Repos still work)
          return handler.next(error);
        },
      ),
    );
    // Optional: add interceptors for logging, auth, etc.
    dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));

    return dio;
  }
}
