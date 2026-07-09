import 'package:dio/dio.dart';

import '../../../../core/constants/api_urls.dart';
import '../../../../core/network/dio_config.dart';
import '../models/app_version_model.dart';

abstract class AppVersionRemoteDataSource {
  Future<AppVersionModel> checkAppVersion();
}

class AppVersionRemoteDataSourceImpl implements AppVersionRemoteDataSource {
  final Dio dio;

  AppVersionRemoteDataSourceImpl(this.dio);

  @override
  Future<AppVersionModel> checkAppVersion() async {
    // No auth, no params. Suppress the global error snackbar — a flaky check
    // must stay invisible (the gate fails open on any error).
    final Response response = await dio.get(
      ApiUrls.appVersionCheck,
      options: Options(extra: {DioConfig.kSilentErrors: true}),
    );
    return AppVersionModel.fromJson(response.data);
  }
}
