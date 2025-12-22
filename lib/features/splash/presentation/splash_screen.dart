import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/constants/app_images.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/constants.dart';
import '../../auth/presentation/auth_router.dart';
import '../../home/presentation/home_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.kToken);

    // Add a small delay to show the splash screen
    await Future.delayed(const Duration(seconds: 2));

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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: SvgPicture.asset(AppImages.logo, fit: BoxFit.cover),
      ),
    );
  }
}
