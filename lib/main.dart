import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/injection_container.dart' as di;
import 'core/routing/router.dart';
import 'core/services/fcm_service.dart';
import 'core/services/location_service.dart';
import 'core/services/shared_preferences_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/home/presentation/bloc/home_bloc.dart';
import 'features/order/presentation/bloc/order_bloc.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await FCMService.initializeFCM();
  await SharedPreferencesService.init();

  // Initialize Location Permissions
  try {
    final locationService = di.sl<LocationService>();
    await locationService.checkAndRequestPermission();
  } catch (e) {
    debugPrint('Error initializing location permissions: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ProfileBloc(getAgentDetails: di.sl()),
        ),
        BlocProvider(create: (context) => di.sl<AuthBloc>()),
        BlocProvider(
          create: (context) =>
              HomeBloc(getOrders: di.sl(), acceptOrder: di.sl()),
        ),
        BlocProvider(
          create: (context) => OrderBloc(
            bluetoothScannerService: di.sl(),
            updateOrder: di.sl(),
            notifyUser: di.sl(),
            locationService: di.sl(), // Inject LocationService
          ),
        ),
      ],
      child: MaterialApp(
        navigatorKey: AppRouter.navigatorKey,
        debugShowCheckedModeBanner: false,
        initialRoute: AppRouter.splash,
        onGenerateRoute: AppRouter.onGenerateRoute,
        theme: AppTheme.lightTheme,
      ),
    );
  }
}
