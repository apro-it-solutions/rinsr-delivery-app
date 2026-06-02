import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_images.dart';
import '../../../core/constants/constants.dart';
import '../../auth/presentation/auth_router.dart';
import '../../home/presentation/home_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const Duration _splashDuration = Duration(seconds: 3);

  Timer? _timer;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(_splashDuration, _navigateToNextScreen);
  }

  Future<void> _navigateToNextScreen() async {
    if (_navigated) return;
    _navigated = true;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.kToken);

    if (!mounted) return;

    if (token == null || token.isEmpty) {
      // If no token, go to login screen
      await Navigator.pushReplacementNamed(context, AuthRouter.login);
    } else {
      // If token exists, go to home screen
      await Navigator.pushReplacementNamed(context, HomeRouter.home);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00AB98),
      body: SizedBox.expand(
        child: Image.asset(
          AppImages.splash,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
