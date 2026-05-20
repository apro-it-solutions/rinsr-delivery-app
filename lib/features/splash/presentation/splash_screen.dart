import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_animations.dart';
import '../../../core/constants/constants.dart';
import '../../auth/presentation/auth_router.dart';
import '../../home/presentation/home_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this);
    _controller.addStatusListener(_onAnimationStatus);
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _navigateToNextScreen();
    }
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
    _controller.removeStatusListener(_onAnimationStatus);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Lottie.asset(
          AppAnimations.splash,
          controller: _controller,
          onLoaded: (composition) {
            _controller
              ..duration = composition.duration
              ..forward();
          },
        ),
      ),
    );
  }
}
