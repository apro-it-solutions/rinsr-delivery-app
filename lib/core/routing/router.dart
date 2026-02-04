import 'package:flutter/material.dart';
import '../../features/auth/presentation/auth_router.dart';
import '../../features/splash/presentation/splash_screen.dart';

import '../../features/home/presentation/home_router.dart';

class AppRouter {
  static const String splash = '/splash';
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      default:
        return null;
    }
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final authRoute = AuthRouter.onGenerateRoute(settings);
    if (authRoute != null) return authRoute;

    final homeRoute = HomeRouter.onGenerateRoute(settings);
    if (homeRoute != null) return homeRoute;

    final splashRoute = generateRoute(settings);
    if (splashRoute != null) return splashRoute;

    return MaterialPageRoute(
      builder: (_) =>
          const Scaffold(body: Center(child: Text('Route not found'))),
    );
  }
}
