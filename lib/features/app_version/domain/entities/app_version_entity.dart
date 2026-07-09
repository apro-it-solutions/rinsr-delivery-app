import 'package:equatable/equatable.dart';

/// Server-provided force-update contract. Only [minSupportedVersion] drives the
/// gate; the store URLs are optional per-platform overrides for the client
/// fallbacks.
class AppVersionEntity extends Equatable {
  final String? minSupportedVersion;
  final String? iosStoreUrl;
  final String? androidStoreUrl;

  const AppVersionEntity({
    this.minSupportedVersion,
    this.iosStoreUrl,
    this.androidStoreUrl,
  });

  @override
  List<Object?> get props => [minSupportedVersion, iosStoreUrl, androidStoreUrl];
}
