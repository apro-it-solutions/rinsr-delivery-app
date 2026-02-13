import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:rinsr_delivery_partner/core/services/bluetooth_scanner_service.dart';
import '../features/auth/data/repositories/auth_repositories_impl.dart';
import '../features/auth/domain/usecases/authenticate_with_backend.dart';
import '../features/auth/domain/usecases/login_with_phone.dart';
import '../features/auth/domain/usecases/verify_phone_otp.dart';
import '../features/home/data/repositories/home_repository_impl.dart';
import '../features/home/domain/usecases/get_orders.dart';
import '../features/profile/data/data_sources/profile_remote_data_source.dart';

import '../core/network/network_info.dart';

import '../features/auth/data/data_sources/auth_remote_datasource.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/bloc/auth_external_services.dart';
import '../features/home/data/data_sources/home_remote_data_source.dart';
import '../features/home/domain/repositories/home_repository.dart';
import '../features/home/presentation/bloc/home_bloc.dart'; // Import added
import '../features/order/data/data_sources/order_remote_data_source.dart';
import '../features/order/data/repositories/order_repositories_impl.dart';
import '../features/order/domain/repositories/order_repository.dart';
import '../features/order/domain/usecases/accept_order.dart';
import '../features/order/domain/usecases/notify_user.dart';
import '../features/order/domain/usecases/update_order.dart';
import '../features/profile/data/repositories/profile_repository_impl.dart';
import '../features/profile/domain/repositories/profile_repository.dart';
import '../features/profile/domain/usecases/get_agent_details.dart';
import '../features/order/presentation/bloc/order_bloc.dart';
import 'network/api_handler.dart';

import 'services/location_service.dart';
import 'network/dio_config.dart';

final sl = GetIt.instance;

/// Initialize all dependencies for the app.
/// Call `await init();` in main() before runApp()
Future<void> init() async {
  //! ---------------------------
  //! Core
  //! ---------------------------
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  sl.registerLazySingleton(() => Connectivity());

  //! Dio
  sl.registerLazySingleton<Dio>(() => DioConfig.createDio());

  //! ApiHandler
  sl.registerLazySingleton(() => ApiHandler());

  //! Services
  sl.registerLazySingleton(() => LocationService());

  //! External Services
  sl.registerLazySingleton<AuthExternalServices>(
    () => AuthExternalServicesImpl(),
  );

  //! ---------------------------
  //! Features
  //! ---------------------------

  // Use Cases
  sl.registerLazySingleton(() => LoginWithPhone(sl()));
  sl.registerLazySingleton(() => VerifyPhoneOtp(sl()));
  sl.registerLazySingleton(() => AuthenticateWithBackend(sl()));
  sl.registerLazySingleton(() => GetOrders(sl()));
  sl.registerLazySingleton(() => UpdateOrder(sl()));
  sl.registerLazySingleton(() => GetAgentDetails(sl()));
  sl.registerLazySingleton(() => NotifyUser(sl()));
  sl.registerLazySingleton(() => AcceptOrder(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoriesImpl(sl(), sl(), sl()),
  );

  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(sl(), sl(), sl()),
  );

  sl.registerLazySingleton<OrderRepository>(
    () => OrderRepositoriesImpl(sl(), sl(), sl()),
  );

  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl(), sl(), sl()),
  );

  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<OrderRemoteDataSource>(
    () => OrderRemoteDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(sl()),
  );

  //! BLoCs
  // HomeBloc MUST be a lazySingleton so that FCMService and UI share the same instance
  sl.registerLazySingleton(() => HomeBloc(getOrders: sl(), acceptOrder: sl()));

  sl.registerFactory(
    () => AuthBloc(
      externalServices: sl(),
      loginWithPhone: sl(),
      verifyPhoneOtp: sl(),
      authenticateWithBackend: sl(),
    ),
  );

  sl.registerLazySingleton<BluetoothScannerService>(
    () => BluetoothScannerService(),
  );

  sl.registerFactory(
    () => OrderBloc(
      updateOrder: sl(),
      notifyUser: sl(),
      locationService: sl(),
      bluetoothScannerService: sl(),
    ),
  );
}
