part of 'version_bloc.dart';

sealed class VersionState extends Equatable {
  const VersionState();

  @override
  List<Object?> get props => [];
}

/// Before the first check completes — treated as "OK, don't block".
final class VersionInitial extends VersionState {
  const VersionInitial();
}

/// The running version is supported (or the check failed open).
final class VersionOk extends VersionState {
  const VersionOk();
}

/// The running version is below `min_supported_version` — hard block.
final class ForceUpdateRequired extends VersionState {
  final AppVersionEntity versionInfo;

  const ForceUpdateRequired(this.versionInfo);

  @override
  List<Object?> get props => [versionInfo];
}
