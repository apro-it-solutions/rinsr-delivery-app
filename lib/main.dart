import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import 'core/injection_container.dart' as di;
import 'core/routing/router.dart';
import 'core/services/background_tracking_service.dart';
import 'core/services/fcm_service.dart';
import 'core/services/location_service.dart';
import 'core/services/shared_preferences_service.dart';
import 'core/theme/app_theme.dart';
import 'features/app_version/presentation/bloc/version_bloc.dart';
import 'features/app_version/presentation/widgets/version_gate.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/home/presentation/bloc/home_bloc.dart';
import 'features/order/presentation/bloc/order_bloc.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Lock the app to portrait — the delivery flow (forms, camera, weighing) is
  // designed for upright use and must never rotate to landscape.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  // Must run before any foreground-service interaction (background tracking).
  FlutterForegroundTask.initCommunicationPort();
  await di.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Prefs must come first: initializeFCM reads the saved agent id to re-sync
  // the device token on every launch (stale-token fix).
  await SharedPreferencesService.init();
  await FCMService.initializeFCM();

  // Initialize Location Permissions
  try {
    final locationService = di.sl<LocationService>();
    await locationService.checkAndRequestPermission();
  } catch (e) {
    debugPrint('Error initializing location permissions: $e');
  }

  // Re-attach to a tracking service left running by a previous session
  // (agent force-killed the app mid-route). Fire-and-forget: must not delay
  // startup.
  unawaited(di.sl<BackgroundTrackingService>().adoptRunningService());

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  // Held here so the resume lifecycle callback can re-dispatch the check.
  late final VersionBloc _versionBloc = di.sl<VersionBloc>()
    ..add(const CheckVersionRequested());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _versionBloc.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-check the required version whenever the app returns to the foreground.
    if (state == AppLifecycleState.resumed) {
      _versionBloc.add(const CheckVersionRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<VersionBloc>.value(value: _versionBloc),
        BlocProvider(
          create: (context) => ProfileBloc(
            getAgentDetails: di.sl(),
            toggleActive: di.sl(),
            updateProfileImage: di.sl(),
          ),
        ),
        BlocProvider(create: (context) => di.sl<AuthBloc>()),
        BlocProvider(
          create: (context) =>
              HomeBloc(getOrders: di.sl(), acceptOrder: di.sl()),
        ),
        BlocProvider(
          create: (context) => OrderBloc(
            cancelOrder: di.sl(),
            bluetoothScannerService: di.sl(),
            updateOrder: di.sl(),
            notifyUser: di.sl(),
            markPaymentReceived: di.sl(),
            getPaymentQr: di.sl(),
            locationService: di.sl(),
            trackingService: di.sl(),
            backgroundTrackingService: di.sl(),
          ),
        ),
      ],
      child: MaterialApp(
        navigatorKey: AppRouter.navigatorKey,
        debugShowCheckedModeBanner: false,
        initialRoute: AppRouter.splash,
        onGenerateRoute: AppRouter.onGenerateRoute,
        theme: AppTheme.lightTheme,
        builder: (context, child) {
          return SafeArea(
            top: false,
            left: false,
            right: false,
            minimum: const EdgeInsets.only(bottom: 10),
            child: VersionGate(child: child ?? const SizedBox.shrink()),
          );
        },
      ),
    );
  }
}
