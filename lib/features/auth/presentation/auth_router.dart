import 'package:flutter/material.dart';

import 'pages/login_screen.dart';
import 'pages/otp_screen.dart';

class AuthRouter {
  static const String login = '/login';
  static const String otp = '/otp';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (context) => const LoginScreen());
      case otp:
        final mobileNumber = settings.arguments as String? ?? '';
        return MaterialPageRoute(
          builder: (context) => OtpScreen(phoneNumber: mobileNumber),
        );
    }
    return null;
  }
}
