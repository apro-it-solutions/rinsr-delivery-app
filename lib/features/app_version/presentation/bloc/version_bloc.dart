import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/version_utils.dart';
import '../../domain/entities/app_version_entity.dart';
import '../../domain/usecases/check_app_version.dart';

part 'version_event.dart';
part 'version_state.dart';

class VersionBloc extends Bloc<VersionEvent, VersionState> {
  final CheckAppVersion checkAppVersion;

  VersionBloc({required this.checkAppVersion}) : super(const VersionInitial()) {
    on<CheckVersionRequested>(_onCheckVersionRequested);
  }

  FutureOr<void> _onCheckVersionRequested(
    CheckVersionRequested event,
    Emitter<VersionState> emit,
  ) async {
    // Fail open: any error (version read, network, non-200, malformed field)
    // must never block. A flaky check falls through to VersionOk.
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      final result = await checkAppVersion.call(const NoParams());

      result.fold(
        (failure) => emit(const VersionOk()),
        (info) {
          final minVersion = info.minSupportedVersion;
          if (minVersion != null &&
              minVersion.isNotEmpty &&
              VersionUtils.isVersionLower(currentVersion, minVersion)) {
            emit(ForceUpdateRequired(info));
          } else {
            emit(const VersionOk());
          }
        },
      );
    } catch (e) {
      debugPrint('Version check failed open: $e');
      emit(const VersionOk());
    }
  }
}
