import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:rinsr_delivery_partner/features/auth/presentation/auth_router.dart';
import '../routing/router.dart';

import '../constants/constants.dart';
import '../services/background_tracking_service.dart';
import '../services/shared_preferences_service.dart';
import '../utils/app_alerts.dart';

class DioConfig {
  /// Set `Options(extra: {DioConfig.kSilentErrors: true})` on a request to
  /// suppress the global error snackbar (e.g. fire-and-forget startup work
  /// like FCM token upload, where a transient DNS/network blip must stay
  /// invisible to the user).
  static const String kSilentErrors = 'silentErrors';

  /// Exposed so the background tracking isolate (which can't reach this Dio
  /// instance) can build its own client against the same API.
  static const String baseUrl = 'https://rinsrapi.aproitsolutions.in/api/';

  static Dio createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
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
          final silentErrors =
              error.requestOptions.extra[kSilentErrors] == true;

          // 1. Handle Logout Scenarios (401/403)
          if (error.response?.statusCode == 401 ||
              error.response?.statusCode == 403) {
            // Only clear auth related data if possible, otherwise clear() is fine but aggressive
            await SharedPreferencesService.clear();

            // Session is gone — stop background driver tracking so its
            // notification (and stale-token POSTs) don't outlive the login.
            try {
              await GetIt.instance<BackgroundTrackingService>().stop();
            } catch (_) {}

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
          else if (!silentErrors &&
              error.response?.statusCode != null &&
              error.response!.statusCode! >= 500) {
            AppAlerts.showErrorSnackBar(
              context: AppRouter.navigatorKey.currentContext!,
              message: 'Server error. Please try again later.',
            );
          }
          // 3. Handle Network/Connection Errors
          else if (!silentErrors &&
              (error.type == DioExceptionType.connectionTimeout ||
                  error.type == DioExceptionType.receiveTimeout ||
                  error.type == DioExceptionType.connectionError)) {
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
    if (kDebugMode) {
      // Optional: add interceptors for logging, auth, etc.
      dio.interceptors.add(
        LogInterceptor(responseBody: true, requestBody: true),
      );
    }

    return dio;
  }
}
